const API_URL = "PLACEHOLDER_API_URL";

fetch(API_URL)
  .then(r => r.json())
  .then(data => document.getElementById("visitor-count").textContent = data.count)
  .catch(() => document.getElementById("visitor-count").textContent = "—");
