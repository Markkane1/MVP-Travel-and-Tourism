import prisma from '../src/lib/prisma';

afterAll(async () => {
  // Clean up any test users we explicitly create
  await prisma.user.deleteMany({
    where: { email: { endsWith: '@integrationtest.local' } },
  });
  await prisma.$disconnect();
});
