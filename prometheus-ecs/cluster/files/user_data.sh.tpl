#cloud-config
package_upgrade: true
packages:
- aws-cli
- nfs-utils
- jq

write_files:

  - path: /root/init_ecs.sh
    permissions: '0755'
    owner: root:root
    content: |
      #!/bin/bash
      set -x
      echo ECS_CLUSTER=${ecs_name} >> /etc/ecs/ecs.config
      start ecs
      
      until $(curl --output /dev/null --silent --head --fail  http://localhost:51678/v1/metadata); do
          printf '.'
          sleep 5
      done

      instance_arn=$(curl -s http://localhost:51678/v1/metadata | jq -r '. | .ContainerInstanceArn' | awk -F/ '{print $NF}' )
      echo "Instance arn is $instance_arn"
      aws ecs start-task --cluster ${ecs_name} --task-definition ${cadvisor_revision} --container-instances $instance_arn --region ${aws_region}
      
  - path: /root/mount_efs.sh
    permissions: '0755'
    owner: root:root
    content: |
      #!/bin/bash
      set -ex

      mkdir ${efs_mount_point}

      EC2_AVAIL_ZONE=`curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone`
      sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2 $EC2_AVAIL_ZONE.${efs_id}.efs.${aws_region}.amazonaws.com:/ ${efs_mount_point}

      aws s3 sync s3://${bucket_config} ${efs_mount_point}
 
runcmd:
- /bin/bash /root/init_ecs.sh
- /bin/bash /root/mount_efs.sh