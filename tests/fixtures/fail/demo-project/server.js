app.get('/x', (req, res) => {
  try { doWork(); } catch (err) { res.json({ error: err.stack }); }
});
