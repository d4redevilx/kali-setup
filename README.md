# Hacking Tools Setup

Este repositorio contiene un conjunto de herramientas y configuraciones útiles para pruebas de penetración, hacking ético y desarrollo de scripts personalizados. El script proporcionado automatiza la configuración de tu entorno de hacking en Kali Linux o cualquier distribución basada en Debian, incluyendo la instalación de herramientas esenciales, la configuración de alias y funciones personalizadas, y la configuración de tu shell.

## Contenido

- **`setup.sh`**: Script principal que configura el sistema, instala dependencias, herramientas de pentesting, y configura el entorno de shell (ZSH).
- **`custom_functions.sh`**: Archivo de funciones personalizadas para facilitar las tareas comunes durante las pruebas de penetración.
- **`.aliases`**: Archivo de alias personalizados para simplificar el uso de comandos repetitivos.
- **`README.md`**: Documentación para explicar cómo configurar y usar el entorno.

## Requisitos

- **Kali Linux** o cualquier distribución basada en Debian.
- **ZSH** (para una mejor experiencia de shell) y **Oh-My-ZSH**.
- **OpenVPN** (si deseas usar la función de conexión a VPN).
- **Dependencias** como `xclip`, `rlwrap`, `wget`, `unzip`, entre otras.

## Instalación

1. Clona el repositorio:

   ```bash
   git clone https://github.com/d4redevilx/kali-setup
   cd kali-setup
