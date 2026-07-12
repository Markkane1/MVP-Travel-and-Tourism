import { ServiceRepository } from '../repositories/ServiceRepository';
import { Prisma, ServiceStatus } from '@prisma/client';

export class CatalogService {
  constructor(private readonly serviceRepository = new ServiceRepository()) {}

  async getAllServices(status?: ServiceStatus) {
    return this.serviceRepository.findAll(status);
  }

  async getServiceById(id: string) {
    return this.serviceRepository.findById(id);
  }

  async createService(data: Prisma.ServiceCreateInput) {
    return this.serviceRepository.create(data);
  }

  async updateService(id: string, data: Prisma.ServiceUpdateInput) {
    return this.serviceRepository.update(id, data);
  }

  async deleteService(id: string) {
    return this.serviceRepository.delete(id);
  }
}
