import { Request, Response } from 'express';
import { CatalogService } from '../services/CatalogService';

export class AdminServiceController {
  constructor(private readonly catalogService = new CatalogService()) {}

  listServices = async (_req: Request, res: Response) => {
    try {
      const services = await this.catalogService.getAllServices();
      res.status(200).json(services);
    } catch (error: any) {
      res.status(500).json({ error: error.message });
    }
  };

  createService = async (req: Request, res: Response) => {
    try {
      const service = await this.catalogService.createService(req.body);
      res.status(201).json(service);
    } catch (error: any) {
      res.status(400).json({ error: error.message });
    }
  };

  updateService = async (req: Request, res: Response) => {
    try {
      const service = await this.catalogService.updateService(req.params.id as string, req.body);
      res.status(200).json(service);
    } catch (error: any) {
      res.status(400).json({ error: error.message });
    }
  };

  deleteService = async (req: Request, res: Response) => {
    try {
      await this.catalogService.deleteService(req.params.id as string);
      res.status(200).json({ message: 'Service deleted successfully' });
    } catch (error: any) {
      res.status(500).json({ error: error.message });
    }
  };
}
