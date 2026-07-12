import prisma from '../lib/prisma';
import { Prisma, Service, ServiceStatus } from '@prisma/client';

export class ServiceRepository {
  async findById(id: string): Promise<Service | null> {
    return prisma.service.findUnique({ where: { id } });
  }

  async findAll(status?: ServiceStatus): Promise<Service[]> {
    return prisma.service.findMany({
      where: status ? { status } : undefined,
    });
  }

  async create(data: Prisma.ServiceCreateInput): Promise<Service> {
    return prisma.service.create({ data });
  }

  async update(id: string, data: Prisma.ServiceUpdateInput): Promise<Service> {
    return prisma.service.update({
      where: { id },
      data,
    });
  }

  async delete(id: string): Promise<Service> {
    return prisma.service.delete({ where: { id } });
  }
}
