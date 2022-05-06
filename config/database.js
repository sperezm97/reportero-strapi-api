module.exports = ({ env }) => ({
  connection: {
    client: 'mysql',
    connection: {
      host: process.env['DATABASE_HOST'] || '127.0.0.1',
      port: process.env['DATABASE_PORT'] || 3306,
      database: process.env['DATABASE_NAME'] || 'reportero',
      user: process.env['DATABASE_USERNAME'] || 'root',
      password: process.env['DATABASE_PASSWORD'] || '',
      ssl: process.env['DATABASE_SSL'] || false,
    },
  },
});
