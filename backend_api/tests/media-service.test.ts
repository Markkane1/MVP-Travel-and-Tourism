import { MediaService } from '../src/services/MediaService';

test('upload signatures only allow supported media folders', () => {
  const service = new MediaService({} as any);

  expect(() => service.generateUploadSignature('tour-media')).not.toThrow();
  expect(() => service.generateUploadSignature('totally-made-up')).toThrow(
    'Unsupported media folder',
  );
});

test('completeUpload rejects multi-target attachments and reuses existing assets', async () => {
  const mediaRepository = {
    getAssetByPublicId: jest.fn().mockResolvedValue({
      id: 'asset-1',
      publicId: 'cloudinary/public-1',
      url: 'https://cdn.example.com/public-1.jpg',
    }),
    createAsset: jest.fn(),
    attachToTour: jest.fn(),
    attachToService: jest.fn(),
  };
  const service = new MediaService(mediaRepository as any);

  await expect(
    service.completeUpload({
      publicId: 'cloudinary/public-1',
      url: 'https://cdn.example.com/public-1.jpg',
      folder: 'tour-media',
      tourId: 'tour-1',
      serviceId: 'service-1',
    }),
  ).rejects.toThrow('Media can only attach to one target');

  const asset = await service.completeUpload({
    publicId: 'cloudinary/public-1',
    url: 'https://cdn.example.com/public-1.jpg',
    folder: 'tour-media',
    tourId: 'tour-1',
  });

  expect(mediaRepository.createAsset).not.toHaveBeenCalled();
  expect(mediaRepository.attachToTour).toHaveBeenCalledWith({
    tourId: 'tour-1',
    mediaAssetId: 'asset-1',
  });
  expect(asset.id).toBe('asset-1');
});
