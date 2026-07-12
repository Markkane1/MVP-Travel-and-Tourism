import { Request, Response } from 'express';
import { TourService } from '../services/TourService';

export class AdminTourController {
  constructor(private readonly tourService = new TourService()) {}

  createTour = async (req: Request, res: Response) => {
    try {
      const tour = await this.tourService.createTour(req.body);
      res.status(201).json(tour);
    } catch (error: any) {
      res.status(400).json({ error: error.message });
    }
  };

  updateTour = async (req: Request, res: Response) => {
    try {
      const tour = await this.tourService.updateTour(req.params.id as string, req.body);
      res.status(200).json(tour);
    } catch (error: any) {
      res.status(400).json({ error: error.message });
    }
  };

  deleteTour = async (req: Request, res: Response) => {
    try {
      await this.tourService.deleteTour(req.params.id as string);
      res.status(200).json({ message: 'Tour deleted successfully' });
    } catch (error: any) {
      res.status(500).json({ error: error.message });
    }
  };

  addItineraryDay = async (req: Request, res: Response) => {
    try {
      const itineraryDay = await this.tourService.addItineraryDay(req.params.id as string, req.body);
      res.status(201).json(itineraryDay);
    } catch (error: any) {
      res.status(400).json({ error: error.message });
    }
  };

  addTourDate = async (req: Request, res: Response) => {
    try {
      const tourDate = await this.tourService.addTourDate(req.params.id as string, req.body);
      res.status(201).json(tourDate);
    } catch (error: any) {
      res.status(400).json({ error: error.message });
    }
  };
}
