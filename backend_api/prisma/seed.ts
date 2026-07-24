import 'dotenv/config';
import prisma from '../src/lib/prisma';
import bcrypt from 'bcryptjs';

async function main() {
  const email = 'admin@travelmvp.com';
  const password = await bcrypt.hash('admin123', 10);
  
  const user = await prisma.user.upsert({
    where: { email },
    update: {
      password,
      role: 'ADMIN',
    },
    create: {
      email,
      password,
      firstName: 'Super',
      lastName: 'Admin',
      role: 'ADMIN',
      status: 'ACTIVE',
    },
  });

  console.log('Admin user seeded:', user);
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
