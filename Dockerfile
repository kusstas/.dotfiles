FROM ubuntu:24.04 AS runner

RUN apt-get update && apt-get install -y sudo

ARG USER_NAME=kusov
ARG USER_UID=1001
ARG USER_GID=1001

RUN groupadd -g ${USER_GID} ${USER_NAME}
RUN useradd -m -s /bin/bash -u ${USER_UID} -g ${USER_GID} ${USER_NAME}
RUN usermod -aG sudo ${USER_NAME}
RUN echo "${USER_NAME} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
ENV HOME /home/${USER_NAME}
RUN chown -R ${USER_NAME}:${USER_NAME} /home/${USER_NAME}

USER kusov
WORKDIR /home/${USER_NAME}

RUN sudo apt install -y zsh build-essential curl git stow cmake
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
RUN curl -sSL https://github.com/zthxxx/jovial/raw/master/installer.sh | sudo -E bash -s ${USER:=`whoami`}

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
RUN .cargo/bin/cargo install cargo-upgrades
RUN .cargo/bin/cargo install cargo-expand
RUN .cargo/bin/cargo install cargo-cache
RUN .cargo/bin/rustup component add rust-analyzer

RUN /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
ENV PATH "$PATH:/home/linuxbrew/.linuxbrew/bin/"
RUN brew install helix yazi zellij lazygit bat
RUN brew install neocmakelsp
RUN brew install bash-language-server
RUN brew install lua-language-server
RUN brew install yaml-language-server yamlfmt
RUN brew install vscode-langservers-extracted
RUN brew install llvm
RUN brew install ruff pylsp
RUN brew install taplo

RUN pip3 install bitbake-language-server --break-system-packages

RUN brew cleanup --prune all

COPY .. .dotfiles
RUN rm -rf .tmux.conf .zshrc
RUN cd .dotfiles && stow -v .
SHELL [ "/bin/zsh", "-c" ]

ENTRYPOINT [ "/bin/zsh" ]
