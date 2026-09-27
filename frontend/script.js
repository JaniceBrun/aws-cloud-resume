const API_URL = "https://n4lsjns23g.execute-api.eu-north-1.amazonaws.com/prod/count";

fetch(API_URL)
  .then(r => r.json())
  .then(data => document.getElementById("visitor-count").textContent = data.count)
  .catch(() => document.getElementById("visitor-count").textContent = "—");
