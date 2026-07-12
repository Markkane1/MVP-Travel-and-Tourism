import { Request, Response } from 'express';
import { ReviewService } from '../services/ReviewService';

export class AdminReviewController {
  constructor(private readonly reviewService = new ReviewService()) {}

  issueReward = async (req: Request, res: Response) => {
    try {
      const review = await this.reviewService.issueReward(req.params.id as string);
      res.status(200).json(review);
    } catch (error: any) {
      res.status(400).json({ error: error.message });
    }
  };
}
