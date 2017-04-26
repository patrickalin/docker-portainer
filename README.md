# docker-portainer
Docker portainer

To add another node

    vi /etc/systemd/system/multi-user.target.wants/docker.service
    
    ExecStart=/usr/bin/dockerd -H tcp://0.0.0.0:2375 -H unix:///var/run/docker.sock
