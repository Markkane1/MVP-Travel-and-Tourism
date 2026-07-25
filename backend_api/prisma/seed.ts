import 'dotenv/config';
import prisma from '../src/lib/prisma';
import bcrypt from 'bcryptjs';

async function main() {
  const adminPassword = await bcrypt.hash('admin123', 10);
  const superAdminPassword = await bcrypt.hash('SuperAdmin123!', 10);

  const admin = await prisma.user.upsert({
    where: { email: 'admin@travelmvp.com' },
    update: {
      password: adminPassword,
      role: 'ADMIN',
      status: 'ACTIVE',
    },
    create: {
      email: 'admin@travelmvp.com',
      password: adminPassword,
      firstName: 'Admin',
      lastName: 'User',
      role: 'ADMIN',
      status: 'ACTIVE',
    },
  });

  const superAdmin = await prisma.user.upsert({
    where: { email: 'superadmin@travelmvp.com' },
    update: {
      password: superAdminPassword,
      role: 'SUPER_ADMIN',
      status: 'ACTIVE',
    },
    create: {
      email: 'superadmin@travelmvp.com',
      password: superAdminPassword,
      firstName: 'Super',
      lastName: 'Admin',
      role: 'SUPER_ADMIN',
      status: 'ACTIVE',
    },
  });

  console.log('Seeded users:', { admin, superAdmin });
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
