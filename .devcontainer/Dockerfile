FROM debian:bookworm

# Update and install necessary packages
RUN DEBIAN_FRONTEND=noninteractive apt update
RUN DEBIAN_FRONTEND=noninteractive apt install -y gcc-multilib g++-multilib cmake git doxygen
RUN apt install -y can-utils kmod iproute2