import prisma from '../lib/prisma';
import { Prisma, Tour, TourItinerary, TourDate, TourStatus } from '@prisma/client';

export class TourRepository {
  async findById(id: string): Promise<Tour | null> {
    return prisma.tour.findUnique({
      where: { id },
      include: { itineraries: true, dates: true },
    });
  }

  async findPublicById(id: string): Promise<Tour | null> {
    return prisma.tour.findFirst({
      where: { id, status: 'PUBLISHED' },
      include: { itineraries: true, dates: true },
    });
  }

  async findDateById(id: string): Promise<(TourDate & { tour: Tour }) | null> {
    return prisma.tourDate.findUnique({
      where: { id },
      include: { tour: true },
    });
  }

  async findAll(status?: TourStatus): Promise<Tour[]> {
    return prisma.tour.findMany({
      where: status ? { status } : undefined,
      include: { itineraries: true, dates: true },
    });
  }

  async create(data: Prisma.TourCreateInput): Promise<Tour> {
    return prisma.tour.create({ data });
  }

  async update(id: string, data: Prisma.TourUpdateInput): Promise<Tour> {
    return prisma.tour.update({
      where: { id },
      data,
    });
  }

  async delete(id: string): Promise<Tour> {
    return prisma.tour.delete({ where: { id } });
  }

  async addItineraryDay(data: Prisma.TourItineraryUncheckedCreateInput): Promise<TourItinerary> {
    return prisma.tourItinerary.create({ data });
  }

  async addTourDate(data: Prisma.TourDateUncheckedCreateInput): Promise<TourDate> {
    return prisma.tourDate.create({ data });
  }
}
