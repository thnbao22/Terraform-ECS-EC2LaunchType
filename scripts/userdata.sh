#!/bin/bash

sudo yum update -y

sudo yum install -y docker

sudo systemctl enable docker

sudo systemctl start docker

sudo usermod -aG docker ec2-user

newgrp docker

mkdir -p /home/ec2-user/nginx-custom-app

cd /home/ec2-user/nginx-custom-app

cat <<'EOF' > index.html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>ECS | Charles DevOps Blog</title>
  <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;600&display=swap" rel="stylesheet">
  <style>
    body {
      margin: 0;
      padding: 0;
      font-family: 'Poppins', sans-serif;
      background: linear-gradient(135deg, #1f2937, #4b5563);
      color: white;
      display: flex;
      flex-direction: column;
      align-items: center;
      justify-content: center;
      height: 100vh;
      overflow: hidden;
      animation: fadeIn 1s ease-in-out;
      position: relative;
    }

    @keyframes fadeIn {
      from { opacity: 0; }
      to { opacity: 1; }
    }

    .cloud-bg {
      position: absolute;
      top: 0;
      left: 0;
      width: 200%;
      height: 200%;
      background: radial-gradient(circle at 20% 30%, rgba(255,255,255,0.05), transparent 40%),
                  radial-gradient(circle at 70% 60%, rgba(255,255,255,0.07), transparent 50%),
                  radial-gradient(circle at 40% 80%, rgba(255,255,255,0.04), transparent 50%);
      animation: floatClouds 30s linear infinite;
      z-index: -2;
    }

    .particles {
      position: absolute;
      top: 0;
      left: 0;
      width: 100%;
      height: 100%;
      pointer-events: none;
      background-image:
        radial-gradient(white 1px, transparent 0),
        radial-gradient(white 1px, transparent 0);
      background-size: 20px 20px, 35px 35px;
      background-position: 0 0, 10px 10px;
      opacity: 0.05;
      animation: floatParticles 60s linear infinite;
      z-index: -1;
    }

    @keyframes floatClouds {
      from { transform: translate(0, 0); }
      to { transform: translate(-20%, -10%); }
    }

    @keyframes floatParticles {
      0% { background-position: 0 0, 10px 10px; }
      100% { background-position: 100px 100px, 120px 120px; }
    }

    .container {
      background-color: rgba(255, 255, 255, 0.05);
      padding: 40px;
      border-radius: 15px;
      box-shadow: 0 8px 20px rgba(0, 0, 0, 0.3);
      text-align: center;
      max-width: 900px;
      position: relative;
      z-index: 1;
    }

    .content-row {
      display: flex;
      align-items: center;
      justify-content: center;
      margin-bottom: 30px;
      gap: 20px;
    }

    .icon-column {
      display: flex;
      flex-direction: column;
      gap: 15px;
      padding: 0 10px;
    }

    .icon {
      width: 40px;
      height: 40px;
      transition: transform 0.3s ease;
    }

    .icon:hover {
      transform: scale(1.2);
    }

    .gif-wrapper {
      position: relative;
      display: flex;
      align-items: center;
      justify-content: center;
    }

    .cloud-aura {
      position: absolute;
      width: 350px;
      height: 350px;
      background: radial-gradient(circle at center, rgba(255,255,255,0.15), transparent 70%);
      border-radius: 50%;
      z-index: 0;
    }

    .main-gif {
      max-width: 300px;
      border-radius: 8px;
      box-shadow: 0 4px 15px rgba(255, 255, 255, 0.2);
      z-index: 1;
    }

    h1 {
      font-size: 28px;
      margin-bottom: 10px;
      font-weight: 600;
    }

    p {
      font-size: 18px;
      margin-top: 5px;
    }

    #date {
      color: #facc15;
      font-weight: 600;
    }
  </style>
</head>
<body>
  <!-- Cloud background layers -->
  <div class="cloud-bg"></div>
  <div class="particles"></div>

  <div class="container">
    <div class="content-row">
      <!-- Left Icons -->
      <div class="icon-column">
        <img class="icon" src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/docker/docker-original.svg" alt="Docker">
        <img class="icon" src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/python/python-original.svg" alt="Python">
        <img class="icon" src="https://raw.githubusercontent.com/gilbarbara/logos/master/logos/terraform.svg" alt="Terraform">
        <img class="icon" src="https://raw.githubusercontent.com/gilbarbara/logos/master/logos/grafana.svg" alt="Grafana">
      </div>

      <!-- Main GIF + Cloud Aura -->
      <div class="gif-wrapper">
        <div class="cloud-aura"></div>
        <img class="main-gif" src="https://images.squarespace-cdn.com/content/v1/5e9e61184a2e5f4b613d5853/1589203361327-OKGR7H58GGGLKW4K1EY1/CC.gif?format=1000w" alt="CloudGif">
      </div>

      <!-- Right Icons -->
      <div class="icon-column">
        <img class="icon" src="https://upload.wikimedia.org/wikipedia/commons/9/93/Amazon_Web_Services_Logo.svg" alt="AWS">
        <img class="icon" src="https://raw.githubusercontent.com/gilbarbara/logos/master/logos/prometheus.svg" alt="Prometheus">
        <img class="icon" src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/gitlab/gitlab-original.svg" alt="GitLab CI">
        <img class="icon" src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/github/github-original.svg" alt="GitHub">
      </div>
    </div>

    <h1>Welcome to my custom nginx application hosted in a Docker container</h1>
    <p>This docker container was deployed: <span id="date"></span></p>
  </div>

  <script>
    var date = new Date();
    document.getElementById("date").innerHTML = date.toLocaleString();
  </script>
</body>
</html>
EOF

cat <<'EOF' > Dockerfile
FROM nginx:1.25.3
COPY index.html /usr/share/nginx/html/

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
EOF

