import { TourRepository } from '../repositories/TourRepository';
import { Prisma, TourStatus } from '@prisma/client';

export class TourService {
  constructor(private readonly tourRepository = new TourRepository()) {}

  async getAllTours(status?: TourStatus) {
    return this.tourRepository.findAll(status);
  }

  async getTourById(id: string) {
    return this.tourRepository.findById(id);
  }

  async getPublicTourById(id: string) {
    return this.tourRepository.findPublicById(id);
  }

  async createTour(data: Prisma.TourCreateInput) {
    return this.tourRepository.create(data);
  }

  async updateTour(id: string, data: Prisma.TourUpdateInput) {
    return this.tourRepository.update(id, data);
  }

  async deleteTour(id: string) {
    return this.tourRepository.delete(id);
  }

  async addItineraryDay(tourId: string, data: Omit<Prisma.TourItineraryUncheckedCreateInput, 'tourId'>) {
    const tour = await this.tourRepository.findById(tourId);
    if (!tour) throw new Error('Tour not found');
    
    return this.tourRepository.addItineraryDay({
      tourId,
      ...data,
    });
  }

  async addTourDate(tourId: string, data: Omit<Prisma.TourDateUncheckedCreateInput, 'tourId'>) {
    const tour = await this.tourRepository.findById(tourId);
    if (!tour) throw new Error('Tour not found');

    return this.tourRepository.addTourDate({
      tourId,
      ...data,
    });
  }
}
