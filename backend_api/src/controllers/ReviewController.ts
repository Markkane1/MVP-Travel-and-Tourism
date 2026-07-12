import { Request, Response } from 'express';
import { ReviewService } from '../services/ReviewService';
import { AuthenticatedRequest } from '../types';

export class ReviewController {
  constructor(private readonly reviewService = new ReviewService()) {}

  submitReview = async (req: AuthenticatedRequest, res: Response) => {
    try {
      const { bookingId, rating, comment } = req.body;
      const review = await this.reviewService.submitReview(req.user!.id, bookingId, rating, comment);
      res.status(201).json(review);
    } catch (error: any) {
      res.status(400).json({ error: error.message });
    }
  };

  updateReview = async (req: AuthenticatedRequest, res: Response) => {
    try {
      const { rating, comment } = req.body;
      const review = await this.reviewService.updateReview(req.user!.id, req.params.id as string, rating, comment);
      res.status(200).json(review);
    } catch (error: any) {
      res.status(400).json({ error: error.message });
    }
  };

  deleteReview = async (req: AuthenticatedRequest, res: Response) => {
    try {
      await this.reviewService.deleteReview(req.user!.id, req.params.id as string);
      res.status(200).json({ message: 'Review deleted' });
    } catch (error: any) {
      res.status(400).json({ error: error.message });
    }
  };
}
