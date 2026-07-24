import { ReviewRepository } from '../repositories/ReviewRepository';
import { BookingService } from './BookingService';
import { UserRepository } from '../repositories/UserRepository';
import { Prisma } from '@prisma/client';

export class ReviewService {
  constructor(
    private readonly reviewRepository = new ReviewRepository(),
    private readonly bookingService = new BookingService(),
    private readonly userRepository = new UserRepository(),
  ) {}

  async submitReview(userId: string, bookingId: string, rating: number, comment?: string) {
    const booking = await this.bookingService.getBookingById(bookingId);
    
    if (!booking || booking.userId !== userId) {
      throw new Error('Booking not found');
    }

    if (booking.status !== 'COMPLETED') {
      throw new Error('You can only review a completed booking');
    }

    const existingReview = await this.reviewRepository.findByBookingId(bookingId);
    if (existingReview) {
      throw new Error('A review for this booking already exists');
    }

    if (!Number.isInteger(rating) || rating < 1 || rating > 5) {
      throw new Error('Rating must be an integer between 1 and 5');
    }

    return this.reviewRepository.create({
      bookingId,
      userId,
      tourId: booking.tourId,
      rating,
      comment,
    });
  }

  async issueReward(reviewId: string) {
    const review = await this.reviewRepository.findById(reviewId);
    if (!review) throw new Error('Review not found');

    if (review.rewardIssued) {
      throw new Error('Reward already issued for this review');
    }

    await this.userRepository.update(review.userId, {
      loyaltyPoints: { increment: 100 },
    });

    return this.reviewRepository.update(reviewId, { rewardIssued: true });
  }

  async getRecentReviews(limit = 5) {
    return this.reviewRepository.findRecent(limit);
  }

  async getTourReviews(tourId: string, limit = 5) {
    return this.reviewRepository.findByTourId(tourId, limit);
  }

  async updateReview(userId: string, reviewId: string, rating: number, comment?: string) {
    const review = await this.reviewRepository.findById(reviewId);
    if (!review || review.userId !== userId) {
      throw new Error('Review not found');
    }

    if (!Number.isInteger(rating) || rating < 1 || rating > 5) {
      throw new Error('Rating must be an integer between 1 and 5');
    }

    return this.reviewRepository.update(reviewId, { rating, comment });
  }

  async deleteReview(userId: string, reviewId: string) {
    const review = await this.reviewRepository.findById(reviewId);
    if (!review || review.userId !== userId) {
      throw new Error('Review not found');
    }

    return this.reviewRepository.delete(reviewId);
  }
}
