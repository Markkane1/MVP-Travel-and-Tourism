import { TourService } from '../src/services/TourService';
import { ReviewService } from '../src/services/ReviewService';

test('public tour lookup does not return draft tours', async () => {
  const tourRepository = {
    findPublicById: jest.fn().mockResolvedValue(null),
  };

  const service = new TourService(tourRepository as any);
  const tour = await service.getPublicTourById('tour-draft');

  expect(tour).toBeNull();
  expect(tourRepository.findPublicById).toHaveBeenCalledWith('tour-draft');
});

test('reward issuance marks the review and grants loyalty points', async () => {
  const reviewRepository = {
    findById: jest.fn().mockResolvedValue({
      id: 'review-1',
      userId: 'user-1',
      rewardIssued: false,
    }),
    update: jest.fn().mockResolvedValue({
      id: 'review-1',
      userId: 'user-1',
      rewardIssued: true,
    }),
  };
  const bookingService = {};
  const userRepository = {
    update: jest.fn().mockResolvedValue({
      id: 'user-1',
      loyaltyPoints: 100,
    }),
  };

  const service = new ReviewService(
    reviewRepository as any,
    bookingService as any,
    userRepository as any,
  );
  const review = await service.issueReward('review-1');

  expect(userRepository.update).toHaveBeenCalledWith('user-1', {
    loyaltyPoints: { increment: 100 },
  });
  expect(reviewRepository.update).toHaveBeenCalledWith('review-1', {
    rewardIssued: true,
  });
  expect(review.rewardIssued).toBe(true);
});
