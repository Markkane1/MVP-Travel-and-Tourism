import { v2 as cloudinary } from 'cloudinary';
import { MediaRepository } from '../repositories/MediaRepository';
import { env } from '../config/env';

// Configure cloudinary with env variables
cloudinary.config({
  cloud_name: env.cloudinaryCloudName,
  api_key: env.cloudinaryApiKey,
  api_secret: env.cloudinaryApiSecret,
});

const allowedFolders = new Set([
  'tour-media',
  'service-media',
  'profile-media',
  'review-media',
  'concierge-attachments',
]);

export class MediaService {
  constructor(private readonly mediaRepository = new MediaRepository()) {}

  generateUploadSignature(folder: string) {
    if (!allowedFolders.has(folder)) {
      throw new Error('Unsupported media folder');
    }

    const timestamp = Math.round(new Date().getTime() / 1000);
    const paramsToSign = {
      timestamp,
      folder,
    };

    const signature = cloudinary.utils.api_sign_request(paramsToSign, env.cloudinaryApiSecret);

    return {
      timestamp,
      signature,
      cloudName: env.cloudinaryCloudName,
      apiKey: env.cloudinaryApiKey,
      folder,
    };
  }

  async completeUpload(assetData: {
    publicId: string;
    url: string;
    resourceType?: string;
    format?: string;
    bytes?: number;
    folder?: string;
    tourId?: string;
    serviceId?: string;
  }) {
    if (!assetData.publicId?.trim() || !assetData.url?.trim()) {
      throw new Error('publicId and url are required');
    }

    if (!assetData.folder || !allowedFolders.has(assetData.folder)) {
      throw new Error('Unsupported media folder');
    }

    const attachmentCount = (assetData.tourId ? 1 : 0) + (assetData.serviceId ? 1 : 0);
    if (attachmentCount > 1) {
      throw new Error('Media can only attach to one target');
    }

    const existingAsset = await this.mediaRepository.getAssetByPublicId(
      assetData.publicId,
    );
    const asset =
      existingAsset ||
      (await this.mediaRepository.createAsset({
        publicId: assetData.publicId,
        url: assetData.url,
        resourceType: assetData.resourceType || 'image',
        format: assetData.format,
        bytes: assetData.bytes,
        folder: assetData.folder,
      }));

    // Attach to relations if provided
    if (assetData.tourId) {
      await this.mediaRepository.attachToTour({
        tourId: assetData.tourId,
        mediaAssetId: asset.id,
      });
    }

    if (assetData.serviceId) {
      await this.mediaRepository.attachToService({
        serviceId: assetData.serviceId,
        mediaAssetId: asset.id,
      });
    }

    return asset;
  }

  async deleteAsset(id: string) {
    const asset = await this.mediaRepository.getAssetById(id);
    if (!asset) throw new Error('Asset not found');

    // Remove from cloudinary
    await cloudinary.uploader.destroy(asset.publicId);

    // Remove from DB (cascade handles relations)
    return this.mediaRepository.deleteAsset(id);
  }
}
