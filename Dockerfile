# === Base image ===
FROM ubuntu:24.04

# === System packages installation ===
RUN apt-get update && \
  apt-get install -y sudo zsh build-essential curl git stow cmake file pkg-config && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

# === User configuration arguments ===
ARG USER_NAME=me
ARG USER_UID=1000
ARG USER_GID=1000

# === Create user and grant passwordless sudo ===
RUN userdel -r ubuntu && \
  groupadd -g ${USER_GID} ${USER_NAME} && \
  useradd -m -s /bin/zsh -u ${USER_UID} -g ${USER_GID} ${USER_NAME} && \
  usermod -aG sudo ${USER_NAME} && \
  echo "${USER_NAME} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# === Switch to non-root user and set environment ===
USER ${USER_NAME}
ENV HOME=/home/${USER_NAME}
WORKDIR ${HOME}

# === Install Oh My Zsh ===
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
RUN git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
RUN git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# === Install Rust toolchain and useful cargo utilities ===
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y && \
  .cargo/bin/rustup component add rust-analyzer && \
  .cargo/bin/cargo install cargo-upgrades && \
  .cargo/bin/cargo install cargo-expand && \
  .cargo/bin/cargo install cargo-cache && \
  rm -rf .cargo/registry

# === Install Homebrew (Linuxbrew) ===
RUN /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
ENV PATH="$PATH:/home/linuxbrew/.linuxbrew/bin/"

# === Install Homebrew packages and language servers ===
RUN brew install helix yazi zellij gitui bat \
  neocmakelsp \
  bash-language-server \
  lua-language-server \
  yaml-language-server yamlfmt \
  vscode-langservers-extracted \
  llvm \
  ruff pylsp \
  taplo && \
  brew cleanup --prune all && \
  rm -rf .cache/Homebrew

# === Python tools installed via pip ===
RUN pip3 install bitbake-language-server --break-system-packages && \
  pip3 cache purge && \
  rm -rf .cache/pip

# === npm tools installed via npm ===
RUN npm install -g @github/copilot@0.0.330

# === Fetch and build Helix editor assets ===
RUN hx -g fetch && hx -g build

# === Copy dotfiles into image and apply them with GNU Stow ===
COPY --chown=${USER_NAME}:${USER_NAME} .. .dotfiles
RUN rm -rf .tmux.conf .zshrc
RUN cd .dotfiles && stow -v .

# === Runtime environment and entrypoint ===
ENV SHELL=/bin/zsh

WORKDIR ${HOME}/workdir
ENTRYPOINT [ "/bin/zsh" ]
