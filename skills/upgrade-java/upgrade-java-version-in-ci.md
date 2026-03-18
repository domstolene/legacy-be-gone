1. Find workflow files that sets java-version:

   ```shell
   rg java-version .github/workflows/
   ```

2. Update all files found to latest Java LTS version.
3. Find jdk docker images in workflows:

   ```shell
   rg openjdk .github/workflows/
   ```

4. If image is from docker hub (docker.io/image/openjdk or just image/name), find new image with:
   1. Version is in image name (docker.io/image/openjdk-25 or image/openjdk-25), find new image with:

      ```shell
      java_version=25 docker search image/openjdk-$java_version
      ```

   2. Version is in image tag (docker.io/eclipse-temurin:25-jre or eclipse-temurin:25-jre):

      ```shell
      image=library/eclipse-temurin \
         token=$(curl -s "https://auth.docker.io/token?service=registry.docker.io&scope=repository:$image:pull" | jq -r .token) \
         curl -s -H "Authorization: Bearer $token" "https://registry-1.docker.io/v2/$image/tags/list" \
         | jq --raw-output '.tags[]' \
         | java_version=25 grep $java_version
      ```


5. If image is from Red Hat.

   ```shell
   timeout 1 docker pull registry.access.redhat.com/ubi9/openjdk-25


   image=library/eclipse-temurin \
      token=$(curl -s "https://auth.docker.io/token?service=registry.docker.io&scope=repository:$image:pull" | jq -r .token) \
      curl -s -H "Authorization: Bearer $token" "https://registry-1.docker.io/v2/$image/tags/list" \
      | jq --raw-output '.tags[]' \
      | java_version=25 grep $java_version

image=ubi9/openjdk-25 \
curl -s "https://registry.access.redhat.com/v2/$image/tags/list" \
| jq --raw-output '.tags[]' \

