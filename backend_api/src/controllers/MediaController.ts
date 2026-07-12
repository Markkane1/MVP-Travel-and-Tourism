import { Request, Response } from 'express';
import { MediaService } from '../services/MediaService';
import { AuthenticatedRequest } from '../types';

export class MediaController {
  constructor(private readonly mediaService = new MediaService()) {}

  getUploadToken = async (req: AuthenticatedRequest, res: Response) => {
    try {
      const folder = req.body.folder || 'general';
      const signatureData = this.mediaService.generateUploadSignature(folder);
      
      res.status(200).json(signatureData);
    } catch (error: any) {
      res.status(500).json({ error: error.message });
    }
  };

  completeUpload = async (req: AuthenticatedRequest, res: Response) => {
    try {
      const assetData = req.body;
      const asset = await this.mediaService.completeUpload(assetData);
      res.status(201).json(asset);
    } catch (error: any) {
      res.status(400).json({ error: error.message });
    }
  };

  deleteMedia = async (req: AuthenticatedRequest, res: Response) => {
    try {
      await this.mediaService.deleteAsset(req.params.id as string);
      res.status(200).json({ message: 'Media deleted successfully' });
    } catch (error: any) {
      res.status(400).json({ error: error.message });
    }
  };
}
