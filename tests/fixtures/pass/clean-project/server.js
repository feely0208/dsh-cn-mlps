app.get('/x', (req, res) => {
  try { doWork(); } catch (err) { logger.error(err); res.status(500).json({ code: 'E_INTERNAL' }); }
});
