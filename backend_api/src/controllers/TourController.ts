import { Request, Response } from 'express';
import { TourService } from '../services/TourService';

export class TourController {
  constructor(private readonly tourService = new TourService()) {}

  getTours = async (req: Request, res: Response) => {
    try {
      const tours = await this.tourService.getAllTours('PUBLISHED');
      res.status(200).json(tours);
    } catch (error: any) {
      res.status(500).json({ error: error.message });
    }
  };

  getTour = async (req: Request, res: Response) => {
    try {
      const tour = await this.tourService.getPublicTourById(req.params.id as string);
      if (!tour) {
        res.status(404).json({ error: 'Tour not found' });
        return;
      }
      res.status(200).json(tour);
    } catch (error: any) {
      res.status(500).json({ error: error.message });
    }
  };
}
