### CI/CD pipeline
In this phase, we set up Jenkins and write CI/CD pipeline for our project

##### Step 1. Jenkins Plugin Setup
- Login with initialAdminPassword
- Create a new admin user with password
- Install necessary plugins:
    . Eclipse Temurin Installer (when you have multiple Jenkins jobs that require different JDK version, use this plugin to setup multiple JDK versions)
    . Config File Provider (to create settings.xml file)
    . Maven Integration 
    . Pipeline Maven Integration 
    . Sonarqube Scanner
    . Docker
    . Docker Pipeline
    . Kubernetes
    . Kubernetes CLI
    . Kubernetes Client API
    . Kubernetes Credentials 
    . Pipeline Stage View

##### Step 2. Jenkins Configure Tools
Here, we need to configure plugins, click on  Manage Jenkins -> Tools 

- Add JDK:
  Name: jdk17
  Install Automatically: Install from adoptium.net
  Version: jdk-17.0.9+9

- Add SonarQube Scanner:
  Name: sonar-scanner
  Version: latest

- Add Maven
  Name: maven3
  Version: latest

- Add Docker
  Name: docker
  Install Automatically: Download from docker.com
  Version: Latest


##### Step 3. Install Trivy on Jenkins Server
``` 
sudo apt-get install wget apt-transport-https gnupg lsb-release
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo apt-key add -
echo deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main | sudo tee -a /etc/apt/sources.list.d/trivy.list
sudo apt-get update
sudo apt-get install trivy -y
```

##### Step 4. Configure SonarQube Server
###### Step 4.1 Generate  Admin Token in Sonarqube Server
 Administration -> Security -> Users -> Administrator -> Tokens


###### Step 4.2 Create Sonarqube Credential with the token above in Jenkins Credentials
Manage Jenkins -> Credentials -> System -> Global -> Kind(Secret Text)


###### Step 4.3 Configure SonarQube Server  in Jenkins
Here, we need to configure SonarQube Server: Manage Jenkins -> System -> Sonarqube Servers -> Add Sonarqube 
- Name: sonar
- Server Url: get sonarqube url (eg http://3.138.178.127:9000 )


##### Step 5. Create Sonarqube webhook for Quality Gate
Administration -> Configuration -> Webhooks -> Create
  Name: jenkins
  URL: http://JENKINS_URL/sonarqube-webhook/ (eg    http://18.226.133.13:8080/sonarqube-webhook/)

##### Step 6. Add Nexus Repo URL to pom.xml file

```
   <distributionManagement>
        <repository>
            <id>maven-releases</id>
            <url>http://3.22.130.67:8081/repository/maven-releases/</url>
        </repository>
        <snapshotRepository>
            <id>maven-snapshots</id>
            <url>http://3.22.130.67:8081/repository/maven-snapshots/</url>
        </snapshotRepository>
    </distributionManagement>
```

##### Step 7. Add Nexus Repo Entrypoint to config file
Manage Jenkins -> Managed Files -> Add a new Config -> Global Maven settings.xml 
  id: global-settings

Then add scroll down till the 'servers', add following:
```
    <server>
      <id>maven-releases</id>
      <username>user</username>
      <password>pass</password>
    </server>
    
    <server>
      <id>maven-snapshots</id>
      <username>user</username>
      <password>pass</password>
    </server>
```

##### Step 8. Add Docker Hub (username and password) creds to Jenkins Credentials



##### Step 9. Create Service Account for Jenkins
SSH to K8S-master, 
1. Create ns webapps ` kubectl create ns webapps
`
2. Create file svc.yml, paste the content from sa.yml

3. Create Service Account `kubectl apply -f sa.yml`


##### Step 9. Create Role 
1. Create file role.yml, paste the content from role.yml

2. Create Role `kubectl apply -f role.yml`


##### Step 9. Create Role Binding 
1. Create file role-binding.yml, paste the content from role-binding.yml

2. Create Role `kubectl apply -f role-binding.yml`

##### Step 10. Create token for Jenkins SA
1. Create file secret-token.yml, paste the content from secret-token.yml

2. Create Role `kubectl apply -f secret-token.yml`

##### Step 11. Save Jenkins SA token to Jenkins Credentials
1. Get the token content
`kubectl describe secrets mysecretname -n webapps`

2. Add credentials in Jenkins Credentials
    kind: secret text
    id: k8s-cred


##### Step 12. Install Kubectl on Jenkins
```
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

chmod +x kubectl

sudo mv kubectl /usr/local/bin/kubectl
```

##### Step 13. Configure Email Notification
Here, we generate app password in Gmail
1.  Manage your Google Account -> Security -> 2-Step Verification -> App passwords -> Generate token for Jenkins

2. Add generated token to Jenkins Credentials
    Username: your email address
    Password: token generated above
    id: gmail-cred

2. Configure Extended E-mail Notification in Jenkins: Manage Jenkins -> System
    SMTP server: smtp.gmail.com
    SMTP Port: 465
    -> Advanced
    - Select SSL
    - Select credentials added above

