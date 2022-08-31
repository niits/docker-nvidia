# Demo chạy mô hình PyTorch với Docker

## Chuẩn bị

### Bước 1: Cài đặt Docker và cài Nvidia container-toolkit

Thực hiện thheo <https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html>

TLDR: Test thử với câu lệnh `sudo docker run --rm --gpus all nvidia/cuda:11.0.3-base-ubuntu20.04 nvidia-smi` nếu chưa có `nvidia-docker2` thì cài bằng các câu lệnh sau:

```bash
distribution=$(. /etc/os-release;echo $ID$VERSION_ID) \
      && curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg \
      && curl -s -L https://nvidia.github.io/libnvidia-container/$distribution/libnvidia-container.list | \
            sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
            sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
```

```bash
sudo apt-get update
sudo apt-get install -y nvidia-docker2

sudo systemctl restart docker
```

Kết quả nên thu được:

```bash
% sudo docker run --rm --gpus all nvidia/cuda:11.0.3-base-ubuntu20.04 nvidia-smi
Wed Aug 31 12:52:14 2022
+-----------------------------------------------------------------------------+
| NVIDIA-SMI 515.65.01    Driver Version: 515.65.01    CUDA Version: 11.7     |
|-------------------------------+----------------------+----------------------+
| GPU  Name        Persistence-M| Bus-Id        Disp.A | Volatile Uncorr. ECC |
| Fan  Temp  Perf  Pwr:Usage/Cap|         Memory-Usage | GPU-Util  Compute M. |
|                               |                      |               MIG M. |
|===============================+======================+======================|
|   0  NVIDIA GeForce ...  Off  | 00000000:01:00.0  On |                  N/A |
| 55%   48C    P0    N/A /  75W |    665MiB /  2048MiB |      0%      Default |
|                               |                      |                  N/A |
+-------------------------------+----------------------+----------------------+
                                                                               
+-----------------------------------------------------------------------------+
| Processes:                                                                  |
|  GPU   GI   CI        PID   Type   Process name                  GPU Memory |
|        ID   ID                                                   Usage      |
|=============================================================================|
+-----------------------------------------------------------------------------+
```

### Bước 2: Build docker

Chuyển về thư mục chính và build image với câu lệnh:

```bash
docker build \
      -t pytorch-dev-env \ # Đặt tên cho image được build ra
      .
```

Kết quả kỳ vọng:

[![asciicast](https://asciinema.org/a/518122.svg)](https://asciinema.org/a/518122)

### Bước 3: Chạy docker đã build

#### Chạy trực tiếp

```bash
docker run \
      --name test_env \
      --mount type=bind,source="$(pwd)"/data,target=/app/data \
      --rm \
      --gpus all \
      pytorch-dev-env \
      python3 src/main.py --epochs 1
```

Trong đó:

- `docker run`: câu lệnh để chạy docker
- `--name test_env`: Đặt tên cho container
- `--mount type=bind,source="$(pwd)"/data,target=/app/data`: mount thư mục `data` vào `/app/data`
- `--rm`: Xóa container khi dừng chạy
- `--gpus all`: Cho phép container sử dụng GPU
- `pytorch-dev-env`:  Tên image cần chạy
- `python3 src/main.py --epochs 1`:  Command để chạy

Kết quả kỳ vọng:

[![asciicast](https://asciinema.org/a/518128.svg)](https://asciinema.org/a/518128)

#### Giữ container luôn chạy và attach shell vào để chạy (không khuyến khích)

```bash
docker run \
      --name test_env \
      -d \
      --mount type=bind,source="$(pwd)"/data,target=/app/data \
      --gpus all \
      pytorch-dev-env \
      python3 -m http.server --directory /home
```

Trong đó:

- `docker run`: câu lệnh để chạy docker
- `--name test_env`: Đặt tên cho container
- `-d`: Chuyển container sang dạng chạy ngầm (`daemon`)
- `--mount type=bind,source="$(pwd)"/data,target=/app/data`: mount thư mục `data` vào `/app/data`
- `--gpus all`: Cho phép container sử dụng GPU
- `pytorch-dev-env`:  Tên image cần chạy
- `python3 -m http.server --directory /home`:  Command bất kỳ để giữ container luôn chạy, ở đây là tạo 1 http server

Kết quả kỳ vọng:

[![asciicast](https://asciinema.org/a/518134.svg)](https://asciinema.org/a/518134)
