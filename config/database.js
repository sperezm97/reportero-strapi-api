module.exports = ({ env }) => 
{
  console.log(process.env);
  const port = process.env['DATABASE_PORT'] && parseInt(process.env['DATABASE_PORT']);

  return {
    connection: {
      client: 'mysql',
      connection: {
        host: process.env['DATABASE_HOST'] || '104.196.187.29',
        port: port || 3306,
        database: process.env['DATABASE_NAME'] || 'reportero',
        user: process.env['DATABASE_USERNAME'] || 'root',
        password: process.env['DATABASE_PASSWORD'] || 'BoezBxeFKhBk0ztk',
        ssl: process.env['DATABASE_SSL'] || false,
      },
    },
  }
}
