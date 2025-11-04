# e-comm Project

## Running the Project

Follow these steps to run the project locally:

1. Navigate to the project directory:

```bash
cd path/to/e-comm 
```

2. Install the `serve` package globally:

```bash
sudo npm install -g serve
```

3. Verify the installation:

```bash
serve -v
```

4. Serve the production build:

```bash
serve -s dist
```

The project should now be running locally, and you can access it in your browser.

## after creating Docker File

# Build Docker image
```bash
docker build -t ecomm-react-app:latest .
```
# Run the container

```bash
docker run -d -p 3000:80 ecomm-react-app:latest
```
# go to the browser and test it.
test the project on localhost

# Login to Docker Hub
```bash
 docker login   
```
# Make the build script executable and run it

```bash
chmod +x build.sh  
./build.sh       
``` 
# Make the deploy script executable and run it

```bash
 chmod +x deploy.sh  
 ./deploy.sh       
 ```         
# Make the push script executable and run it for Docker Hub Setup
# Create two repositories automatic in Docker Hub account:
# dev → Public
# prod → Private

```bash
chmod +x push-images.sh    
 ./push-images.sh 
 ```
# Move it to a safe location (Mac/Linux)
   mv ~/Downloads/jenkins-key.pem ~/.ssh/
   
   # Set correct permissions (MUST DO THIS!)
   ```bash
   chmod 400 ~/.ssh/jenkins-key.pem
```

   **For Windows:**
   - Save the file in a known location like `C:\Users\YourName\aws-keys\`
   - You'll use this file with PuTTY or Windows Terminal

---

#### **If You Already Have a Key Pair:**

1. Click the dropdown under "Key pair name"
2. Select your existing key pair from the list
3. Skip the creation steps above

---

### **Step 7: Network Settings - Configure Security Group**

This is the second part you asked about. Here's the detailed walkthrough:

#### **A. Click "Edit" next to Network Settings**

You'll see several options. Configure as follows:

#### **B. Firewall (Security Groups)**

1. **Select:** ● **Create security group** (radio button)

2. **Fill in details:**
```
   Security group name: jenkins-sg
   Description: Security group for Jenkins server
```

#### **C. Inbound Security Group Rules**

You need to add 2 rules. Here's how:

---

**RULE 1: SSH Access (Default - Already there)**

You'll see this rule already exists:
```
Type: ssh
Protocol: TCP
Port range: 22
Source type: My IP
Source: [Your IP will be auto-filled]
Description: SSH access
```

**Action:** Leave as is, but verify:
- **Source type dropdown**: Select **"My IP"**
  - This automatically fills your current IP address
  - This means ONLY you can SSH into this server
  - This is secure! ✅

---

**RULE 2: Jenkins Web UI (You need to ADD this)**

1. **Click**: **"Add security group rule"** (button below Rule 1)

2. **Fill in the new rule:**
```
   Type: Custom TCP Rule
   Protocol: TCP
   Port range: 8080
   Source type: My IP
   Source: [Your IP - auto-filled]
   Description: Jenkins Web UI
```

   **Step-by-step for this rule:**
   - **Type dropdown**: Select **"Custom TCP"**
   - **Port range**: Type **8080**
   - **Source type dropdown**: Select **"My IP"**
   - **Description**: Type **Jenkins Web UI**

---

#### **D. Your Inbound Rules Should Now Look Like This:**
```
┌─────────┬──────────┬──────┬──────────────┬───────────────────┐
│ Rule #  │   Type   │ Port │    Source    │   Description     │
├─────────┼──────────┼──────┼──────────────┼───────────────────┤
│ Rule 1  │   SSH    │  22  │ My IP        │ SSH access        │
│ Rule 2  │ Custom   │ 8080 │ My IP        │ Jenkins Web UI    │
└─────────┴──────────┴──────┴──────────────┴───────────────────┘
```

---

#### **E. Outbound Rules**

Scroll down, you'll see:
```
Outbound rules: Allow all outbound traffic
```

**Action:** Leave this as default (don't change anything)

This allows Jenkins to:
- Download packages from the internet
- Connect to GitHub
- Push to Docker Hub
- Everything it needs to function

---

### **Step 8: Configure Storage**
```
Size (GiB): 8 (default is fine)
Volume Type: gp3 (default)
```

**Action:** Leave as default, no changes needed.

---

### **Step 9: Advanced Details**

**Action:** Leave everything as default, scroll past this section.

---

### **Step 10: Summary (Right side panel)**

Review your settings:
```
✓ Name: jenkins-server
✓ AMI: Ubuntu Server 22.04 LTS
✓ Instance type: t2.small (or t2.micro)
✓ Key pair: jenkins-key
✓ Security group: jenkins-sg (2 rules)
✓ Storage: 8 GB gp3
```

---

### **Step 11: Launch Instance**

1. **Click the orange button**: **"Launch instance"**

2. You'll see: ✅ **"Successfully initiated launch of instance"**

3. **Click**: **"View all instances"**

4. **Wait 2-3 minutes** for:
   - Instance State: **Running** (green)
   - Status Check: **2/2 checks passed** (green checkmark)

---

## **PART 2: Verify Your Setup**

### **Check Your Instance Details:**

1. **Select your instance** (checkbox)
2. Look at the **Details** tab below
3. **Note these important details:**

Instance ID: i-0xxxxxxxxxxxxx
Public IPv4 address: XX.XXX.XXX.XXX  ← You'll need this!
Public IPv4 DNS: ec2-XX-XXX-XXX-XXX.compute-1.amazonaws.com
Key pair assigned: jenkins-key
Security groups: jenkins-sg


## Recommended Setup Architecture
```
┌─────────────────┐
│   GitHub Repo   │ (Your code)
└────────┬────────┘
         │ (Webhook triggers)
         ▼
┌─────────────────┐
│  EC2 Instance 1 │ ← Jenkins Server (t2.small recommended, but t2.micro works)
│   Jenkins CI    │    - Builds Docker images
└────────┬────────┘    - Pushes to Docker Hub
         │             - Deploys to App Server
         ▼
┌─────────────────┐
│  Docker Hub     │ (dev & prod repos)
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  EC2 Instance 2 │ ← Application Server (t2.micro)
│   Your App      │    - Runs your Docker container
│   + Monitoring  │    - Port 80 accessible to all
└─────────────────┘    - SSH only from your IP
```

---

## **Step-by-Step: Complete AWS + Jenkins Setup**

### **STEP 1: Launch Jenkins EC2 Instance**

**AWS Console → EC2 → Launch Instance:**
```
Name: jenkins-server
AMI: Ubuntu Server 22.04 LTS
Instance Type:t2.micro (will work but slower)
Key Pair: Create new or select existing-
we have created - my-ec2-key-20.pem 
```

**Security Group for Jenkins:**
```
Name: jenkins-sg

Inbound Rules:
┌──────────┬──────┬──────────────┬─────────────────┐
│   Type   │ Port │    Source    │   Description   │
├──────────┼──────┼──────────────┼─────────────────┤
│   SSH    │  22  │   My IP      │ SSH access      │
│ Custom   │ 8080 │   My IP      │ Jenkins Web UI  │
└──────────┴──────┴──────────────┴─────────────────┘

Outbound Rules: All traffic (default)
```

After that, connect to Jenkins EC2 instance and run:

```bash
# Connect to Jenkins EC2
ssh -i your-key.pem ubuntu@JENKINS_EC2_PUBLIC_IP
// use public ip address form the EC2 AWS

# Update system
sudo apt update && sudo apt upgrade -y

# Install Java 17 (required for Jenkins)
sudo apt install -y openjdk-17-jdk

# Verify Java installation
java -version

# Add Jenkins repository key
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee \
  /usr/share/keyrings/jenkins-keyring.asc > /dev/null

# Add Jenkins repository
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null

# Update package list
sudo apt update

# Install Jenkins
sudo apt install -y jenkins

# Start Jenkins service
sudo systemctl start jenkins
sudo systemctl enable jenkins

# Check Jenkins status
sudo systemctl status jenkins

# Install Docker (Jenkins needs Docker to build images)
curl -fsSL https://get.docker.com | sudo sh

# Add Jenkins user to Docker group (IMPORTANT!)
sudo usermod -aG docker jenkins

# Restart Jenkins to apply Docker permissions
sudo systemctl restart jenkins

# Get initial admin password
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```

Copy the **initial admin password** - you'll need it in the next step.


---

### **STEP 3: Configure Jenkins (Web Browser)**

1. **Open Jenkins in browser:**
```
http://JENKINS_EC2_PUBLIC_IP:8080
```
2. **Unlock Jenkins:**
   - Paste the initial admin password you copied
   - Click **Continue**

3. **Install Plugins:**
   - Select **Install suggested plugins**
   - Wait for installation to complete (2–3 minutes)

4. **Create First Admin User:**
```
Username: admin
Password: [create a strong password]
Full name: Your Name
Email: your-email@example.com
```
Click **Save and Continue**

5. **Instance Configuration:**
   - Jenkins URL: `http://JENKINS_EC2_PUBLIC_IP:8080/`
   - Click **Save and Finish**

6. **Start using Jenkins**

---

### **STEP 4: Install Required Jenkins Plugins**

1. Go to: **Manage Jenkins → Plugins → Available plugins**
2. Search and install these plugins:
   - ✅ Docker Pipeline
   - ✅ GitHub Integration Plugin
   - ✅ Git Plugin (usually pre-installed)
3. Click: **Download now and install after restart**
4. Restart Jenkins:
   - Check the box: *Restart Jenkins when no jobs are running*
   - Or manually visit: `http://JENKINS_EC2_IP:8080/restart`

---

### **STEP 5: Add Docker Hub Credentials to Jenkins**

1. Go to: **Manage Jenkins → Credentials → System → Global credentials (unrestricted)**
2. Click: **Add Credentials**
3. Fill in:


```
Kind: Username with password
Scope: Global
Username: [jyotikashyap1502]
Password: [your Docker Hub password] // login via GitHub so use a Docker Hub Access Token instead of a password and keep it safe place
ID: jenkins-token	
Description: Docker Hub Credentials

When creating your Docker Hub Access Token

Docker Hub will ask for:

Access permissions
→ Choose between Read-only, Read, Write, Delete, etc.
```
## STEP 6: Update Your Jenkinsfile

## **STEP 7: Create Jenkins Pipeline Job**

**In Jenkins Web UI:**

1. **Click:** New Item

2. **Enter:**
```
   Item name: ecomm-cicd-pipeline
   Type: Pipeline
```
   Click **OK**

3. **General Section:**
   - ✅ Check: **GitHub project**
   - Project url: `https://github.com/YOUR_USERNAME/ecomm-devops-project/`

4. **Build Triggers:**
   - ✅ Check: **GitHub hook trigger for GITScm polling**
   - ✅ Check: **Poll SCM**
   - Schedule: `H/5 * * * *` (checks every 5 minutes as backup)

5. **Pipeline Section:**
   - Definition: **Pipeline script from SCM**
   - SCM: **Git**
   - Repository URL: `https://github.com/YOUR_USERNAME/ecomm-devops-project.git`
   - Credentials: **- none -** (if public repo)
   
   **Branches to build:** Click "Add Branch"
   - Branch Specifier: `*/dev`
   - Click "Add Branch" again
   - Branch Specifier: `*/main`

   - Script Path: `Jenkinsfile`

6. **Save**



## **STEP 8: Setup GitHub Webhook**

```
1. **Go to your GitHub repository** in browser

2. **Settings → Webhooks → Add webhook**

3. **Configure:**
```
   Payload URL: http://JENKINS_EC2_PUBLIC_IP:8080/github-webhook/
   Content type: application/json
   Secret: (leave empty)
   SSL verification: Disable (since we're using HTTP)
   
   Which events would you like to trigger this webhook?
   ● Just the push event
   
   ✅ Active
Add webhook
Test it: GitHub will send a test ping - check if you get a green checkmark

# On your local machine
cd path/to/e-comm

# Make a small change
echo "# Jenkins webhook test" >> README.md

# Commit and push to dev branch
git checkout dev
git add README.md
git commit -m "Test: Jenkins webhook trigger"
git push origin dev

# Watch Jenkins - it should automatically start building!


Go to Jenkins and check if a new build started automatically. This proves the webhook is working.





##  **What Should Happen When You Push Code:**

```
Step 1: You push code to GitHub (dev branch)
   ↓
Step 2: GitHub sends webhook to Jenkins
   ↓
Step 3: Jenkins receives notification
   ↓
Step 4: Jenkins automatically starts building
   ↓
Step 5: Checks out code from dev branch
   ↓
Step 6: Builds Docker image
   ↓
Step 7: Pushes to jyotikashyap1502/ecomm-react-app:dev
   ↓
Step 8: Build completes ✅
 
final testing on 4th nov -v1 