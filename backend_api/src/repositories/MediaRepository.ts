import prisma from '../lib/prisma';
import { Prisma, MediaAsset, TourMedia, ServiceMedia } from '@prisma/client';

export class MediaRepository {
  async createAsset(data: Prisma.MediaAssetUncheckedCreateInput): Promise<MediaAsset> {
    return prisma.mediaAsset.create({ data });
  }

  async getAssetById(id: string): Promise<MediaAsset | null> {
    return prisma.mediaAsset.findUnique({ where: { id } });
  }

  async getAssetByPublicId(publicId: string): Promise<MediaAsset | null> {
    return prisma.mediaAsset.findUnique({ where: { publicId } });
  }

  async deleteAsset(id: string): Promise<MediaAsset> {
    return prisma.mediaAsset.delete({ where: { id } });
  }

  async attachToTour(data: Prisma.TourMediaUncheckedCreateInput): Promise<TourMedia> {
    return prisma.tourMedia.create({ data });
  }

  async attachToService(data: Prisma.ServiceMediaUncheckedCreateInput): Promise<ServiceMedia> {
    return prisma.serviceMedia.create({ data });
  }
}
