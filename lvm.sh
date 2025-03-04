#!/bin/bash
####### Script creado por ACM aka CiberDosis
####### Script de Configuracion de lvm segun el caso de uso: 
green="\e[0;32m\033[1m"
end="\033[0m\e[0m"
blue="\e[0;34m\033[1m"
red="\e[0;31m\033[1m"
yellow="\e[0;33m\033[1m"
gray="\e[0;37m\033[1m"
##########################################################
function ctrl_c(){
    echo -e "${red}\n[!]${end} ${gray}Saliendo...${end}\n"
    exit 1
}
trap ctrl_c INT
###########################################################
function help_lvm(){
    clear
    echo -e "${blue}=============================================================${end}"
    echo -e "${green}               ✦ Guía sobre LVM (Logical Volume Manager) ✦${end}"
    echo -e "${blue}=============================================================${end}\n"

    echo -e "${yellow} 1. ¿Qué es LVM?${end}"
    echo -e "   ${gray}LVM (Logical Volume Manager) es un sistema de gestión de almacenamiento flexible.${end}"
    echo -e "   ${gray}Permite crear, ampliar, reducir y mover volúmenes de disco sin interrumpir el sistema.${end}\n"

    echo -e "${yellow} 2. Conceptos Clave:${end}"
    echo -e "   - ${green}PV (Physical Volume):${end} ${gray}Dispositivos físicos (discos o particiones) usados por LVM.${end}"
    echo -e "   - ${green}VG (Volume Group):${end} ${gray}Agrupación de volúmenes físicos en un solo recurso de almacenamiento.${end}"
    echo -e "   - ${green}LV (Logical Volume):${end} ${gray}Unidades de almacenamiento creadas dentro de un VG, pueden crecer o reducirse.${end}"
    echo -e "   - ${green}Filesystem:${end} ${gray}Sistema de archivos utilizado en un LV (ej: ext4, xfs, etc.).${end}\n"

    echo -e "${yellow} 3. Requisitos para trabajar con LVM:${end}"
    echo -e "   - ${gray}Disponer de al menos un disco o partición para crear un volumen físico (PV).${end}"
    echo -e "   - ${gray}Tener un grupo de volúmenes (VG) donde se almacenarán los volúmenes lógicos.${end}"
    echo -e "   - ${gray}Crear un volumen lógico (LV) dentro del VG y formatearlo con un sistema de archivos.${end}\n"

    echo -e "${yellow} 4. Comandos básicos de LVM:${end}"
    echo -e "   ${blue} Ver información de discos:${end} ${gray}lsblk${end}"
    echo -e "   ${blue} Crear un volumen físico (PV):${end} ${gray}pvcreate /dev/sdX${end}"
    echo -e "   ${blue} Crear un grupo de volúmenes (VG):${end} ${gray}vgcreate MiVG /dev/sdX${end}"
    echo -e "   ${blue} Crear un volumen lógico (LV):${end} ${gray}lvcreate -L 20G -n MiLV MiVG${end}"
    echo -e "   ${blue} Extender un volumen lógico:${end} ${gray}lvextend -L +10G /dev/MiVG/MiLV${end}"
    echo -e "   ${blue} Redimensionar el sistema de archivos:${end} ${gray}resize2fs /dev/MiVG/MiLV${end} ${green}(para ext4)${end}\n"

    echo -e "${yellow} 5. Información adicional:${end}"
    echo -e "   ${gray}Para más detalles, consulta la documentación oficial o usa:${end}"
    echo -e "   ${blue}man lvm${end}\n"

    echo -e "${blue}=============================================================${end}"
    echo -e "${green}                Listo para trabajar con LVM ${end}"
    echo -e "${blue}=============================================================${end}\n"

    exit 0
}
# Procesamiento de opciones con getopts
while getopts "h" opt; do
    case $opt in
        h) help_lvm ;;
        *) echo -e "${red}Opción no válida.${end} Usa -h para ver la ayuda."; exit 1 ;;
    esac
done
###########################################################
function inicio(){
    clear
    echo -e "${blue}=============================================================${end}"
    echo -e "${green}        ✦ Bienvenido al Script de Gestión de LVM ✦${end}"
    echo -e "${blue}=============================================================${end}\n"

    echo -e "${yellow}[+]${end} ${gray}Este script ha sido diseñado para facilitar la gestión y ampliación${end}"
    echo -e "${gray}de volúmenes lógicos (LV) en entornos con LVM (Logical Volume Manager).${end}\n"

    echo -e "${yellow}[→]${end} ${green}Objetivo del programa:${end}"
    echo -e "   ${gray}- Permitir la administración flexible del almacenamiento.${end}"
    echo -e "   ${gray}- Facilitar la expansión de volúmenes lógicos sin afectar los datos.${end}"
    echo -e "   ${gray}- Proporcionar un flujo de trabajo guiado e interactivo.${end}\n"

    echo -e "${yellow}[→]${end} ${green}¿Qué debes saber antes de usar este script?${end}"
    echo -e "   ${gray}- LVM es un sistema de gestión de almacenamiento avanzado.${end}"
    echo -e "   ${gray}- Los datos no se almacenan en particiones tradicionales, sino en LV.${end}"
    echo -e "   ${gray}- Es necesario conocer los volúmenes físicos (PV), grupos de volúmenes (VG)${end}"
    echo -e "     ${gray}y volúmenes lógicos (LV) antes de realizar cambios.${end}\n"

    echo -e "${yellow}[→]${end} ${green}Modo de uso:${end}"
    echo -e "   ${gray}- Sigue las instrucciones interactivas para proporcionar la información${end}"
    echo -e "     ${gray}necesaria y realizar operaciones sobre los volúmenes.${end}"
    echo -e "   ${gray}- Usa la opción ${blue}-h${end} para ver una explicación detallada sobre LVM:${end}"
    echo -e "     ${red}bash "script.sh" -h${end}\n"

    echo -e "${blue}=============================================================${end}"
    echo -e "${yellow}⚡ Preparando entorno...${end}"
    sleep 2
    echo -e "\n"
    comprobaciones
}
function comprobaciones(){
    
    declare -A paquetes
    paquetes=(
        ["lsscsi"]="lsscsi"
        ["vgdisplay"]="lvm2"
        ["lvdisplay"]="lvm2"
        ["partprobe"]="parted"
        ["fdisk"]="fdisk"
        ["lsblk"]="util-linux"
        ["df"]="coreutils"
        ["pvcreate"]="lvm2"
        ["vgcreate"]="lvm2"
        ["lvcreate"]="lvm2"
        ["lvextend"]="lvm2"
        ["resize2fs"]="e2fsprogs"
        ["xfs_growfs"]="xfsprogs"
        ["vgextend"]="lvm2"
        ["lvremove"]="lvm2"
        ["vgremove"]="lvm2"
        ["pvremove"]="lvm2"
        ["blkid"]="util-linux"
        ["mount"]="util-linux"
        ["umount"]="util-linux"
        ["e2fsck"]="e2fsprogs"
        ["xfs_repair"]="xfsprogs"
        ["parted"]="parted"
        ["mkfs.ext4"]="e2fsprogs"
        ["mkfs.xfs"]="xfsprogs"
        ["lvdisplay"]="lvm2"
        ["pvs"]="lvm2"
        ["lvs"]="lvm2"
        ["pvresize"]="lvm2"
        ["partprobe"]="parted"
    )

    # Lista de paquetes a instalar
    paquetes_a_instalar=()

    # Verificar disponibilidad de cada comando y almacenar los que faltan
    for cmd in "${!paquetes[@]}"; do
        if ! command -v "$cmd" &> /dev/null; then
            paquetes_a_instalar+=("${paquetes[$cmd]}")
        fi
    done

    # Si faltan paquetes, proceder con la instalación
    if [ ${#paquetes_a_instalar[@]} -gt 0 ]; then
        echo -e "\n${yellow}Se han detectado paquetes faltantes. Procediendo con la instalación...${end}\n"
        sleep 1

        
        echo -e "${yellow}Actualizando repositorios...${end}\n"
        apt-get update -y &> /dev/null

        
        for pkg in "${paquetes_a_instalar[@]}"; do
            echo -e "${gray}Instalando:${end} ${green}$pkg...${end}"
            apt install -y "$pkg" &> /dev/null
        done

        echo -e "\n${green}✔️  OK - Todos los paquetes están instalados.${end}\n"
    fi

    echo -e "\n${green}✔️  Verificación completa. No se detectaron errores.${end}\n"
    echo -e "\n"
    read -p "Pulsa ENTER para continuar..."
    use_case
}
function use_case(){
    clear
    echo -e "${blue}=============================================================${end}"
    echo -e "${green}                  ✦ Casos de Uso de LVM ✦${end}"
    echo -e "${blue}=============================================================${end}\n"

    echo -e " ${gray}[${end}${red}X${end}${gray}]${end} ${green}Esquema actual de los discos:${end}"
    lsblk

    echo -e "${blue}=============================================================${end}\n"

    echo -e "${gray}Selecciona una opción para continuar:${end}\n"

    echo -e "${blue}=============================================================${end}\n"

    echo -e " ${gray}[${end}${red}1${end}${gray}]${end} ${green}Extender discos a un disco en concreto${end}"
    echo -e "       ${gray}→ Tienes un disco con LVM y quieres añadir X discos a ese volumen LVM ya existente.${end}\n"

    echo -e "${blue}=============================================================${end}\n"

    echo -e " ${gray}[${end}${red}2${end}${gray}]${end} ${green}Extender partición existente${end}"
    echo -e "       ${gray}→ Has ampliado el tamaño del disco con LVM y necesitas extender la partición dentro de LVM.${end}\n"

    echo -e "${blue}=============================================================${end}\n"

    echo -e " ${gray}[${end}${red}3${end}${gray}]${end} ${green}Crear partición y extender volumen${end}"
    echo -e "       ${gray}→ Quieres crear una nueva partición en un disco ampliado y añadirla a la partición LVM existente.${end}\n"

    echo -e "${blue}=============================================================${end}\n"

    echo -e " ${gray}[${end}${red}4${end}${gray}]${end} ${green}Generar disco con LVM${end}"
    echo -e "       ${gray}→ Quieres configurar un nuevo disco desde cero y crear un volumen LVM en él.${end}\n"

    echo -e "${blue}=============================================================${end}\n"

    echo -e " ${gray}[${end}${red}5${end}${gray}]${end} ${yellow}Salir.${end}\n"

    echo -e "${blue}=============================================================${end}\n"

    echo -e "${blue}[-]${end}${yellow} Ingresa el número de la opción deseada:${end} \n" && read opcion_caso_uso

    case $opcion_caso_uso in
        1) info_general_caso_uso_1 ;;
        2) info_general_caso_uso_2 ;;
        3) info_general_caso_uso_3 ;;
        4) info_general_caso_uso_4 ;;
        5) clear; exit; ;;  # Llamar al menú principal
        *) 
            echo -e "${red}[!] Opción no válida. Inténtalo de nuevo.${end}"
            sleep 2
            use_case
        ;;
    esac
}
# Funciones de cada caso de uso 
function extender_a_disco(){
    clear
    echo -e "${blue}=============================================================${end}"
    echo -e "${green}         ✦ Extender discos a un disco LVM existente ✦${end}"
    echo -e "${blue}=============================================================${end}\n"

    echo -e "${yellow}[+] Utilizando la información recopilada en la Información General...${end}\n"
    sleep 1

    # Convertimos las variables en listas
    discos_list=($disco)
    id_list=($ID_DISK)

    # Iteramos sobre los discos y sus identificadores
    for i in "${!discos_list[@]}"; do
        disk_device="/dev/${discos_list[$i]}"
        partition="${disk_device}1"
        id="${id_list[$i]}"  # Obtener el identificador correspondiente al disco

        echo -e "\n${blue}[+] Creando partición en $disk_device...${end}"
        fdisk "$disk_device" <<EOF
n
p
1


t
8e
w
EOF

        # Rescanear el disco utilizando su identificador correcto
        echo -e "${blue}[+] Rescaneando el disco con identificador: $id${end}"
        echo 1 > "/sys/class/scsi_device/$id/device/rescan"

        # Crear el volumen físico (PV) en la nueva partición
        pvcreate "$partition"

        # Añadir la nueva partición al grupo de volúmenes
        vgextend "$vg_option" "$partition"
        echo -e "${green}[✔] Partición $partition añadida a $vg_option${end}\n"
    done

    # Obtener el volumen lógico existente
    echo -e "${blue}[+] Se ha identific
    ado el volumen lógico: $LV_PATH${end}"

    # Extender el volumen lógico para usar el nuevo espacio disponible
    lvextend -l +100%FREE "$LV_PATH"
    echo -e "${green}[✔] Se ha extendido el volumen lógico $LV_PATH${end}"

    # Obtener el sistema de archivos actual
    echo -e "${blue}[+] Sistema de archivos detectado: $FS_TYPE${end}"

    # Extender el sistema de archivos según su tipo
    case $FS_TYPE in
        ext2|ext3|ext4)
            resize2fs "$LV_PATH"
            echo -e "${green}[✔] Se ha extendido el sistema de archivos EXT4${end}"
            ;;
        xfs)
            xfs_growfs "$LV_PATH"
            echo -e "${green}[✔] Se ha extendido el sistema de archivos XFS${end}"
            ;;
        *)
            echo -e "${red}[✗] Tipo de sistema de archivos no compatible: $FS_TYPE${end}"
            ;;
    esac

    echo -e "\n${green}[✔] Proceso finalizado con éxito.${end}"
    echo -e "${blue}=============================================================${end}"
    lsblk
    echo -e "${blue}=============================================================${end}"
    read -p "Pulsa ENTER para volver al menú..."
    use_case
}
function extender_particion_existente(){
    clear
    echo -e "${blue}=============================================================${end}"
    echo -e "${green}      ✦ Extensión de Partición LVM Existente ✦${end}"
    echo -e "${blue}=============================================================${end}\n"

    # Validación previa para evitar pérdida de datos
    echo $particion
    echo -e "${yellow}[⚠] ADVERTENCIA: Se realizarán cambios en la partición ${particion}.${end}"
    echo -e "${yellow}Se recomienda hacer una copia de seguridad antes de continuar.${end}"
    read -p "¿Deseas continuar? (yes/no): " confirmacion
    if [[ "$confirmacion" != "yes" ]]; then
        echo -e "${red}[✗] Operación cancelada.${end}"
        exit 1
    fi
    # Redimensionar la partición existente
    # Extraer el número de partición de la ruta /dev/sdXn
    num_particion=$(echo "$particion" | grep -o '[0-9]*$')

    # Validar si la partición existe realmente antes de modificarla
    if [[ ! -b "$particion" ]]; then
        echo -e "${red}[✗] Error: La partición ${particion} no existe en el sistema.${end}"
        exit 1
    fi

    echo -e "${yellow}[+] Redimensionando la partición en $particion (número: $num_particion)...${end}"
    parted "$disk_device" resizepart "$num_particion" 100% <<EOF
Yes
EOF

    echo -e "${yellow}[+] Actualizando la tabla de particiones...${end}"
    partprobe "$disk_device"
    sleep 2

    echo -e "${yellow}[+] Rescaneando el disco con identificador: $ID_DISK${end}"
    echo 1 > "/sys/class/scsi_device/$ID_DISK/device/rescan"

    echo -e "${yellow}[+] Expandiendo el volumen físico en $particion...${end}"
    pvresize "$particion"

    echo -e "${yellow}[+] Extendiendo el volumen lógico: $LV_PATH...${end}"
    lvextend -l +100%FREE "$LV_PATH"

    echo -e "${blue}[+] Sistema de archivos detectado: $FS_TYPE${end}"

    # Extender el sistema de archivos según su tipo
    case $FS_TYPE in
        ext2|ext3|ext4)
            echo -e "${yellow}[+] Redimensionando el sistema de archivos EXT4 en $LV_PATH...${end}"
            resize2fs "$LV_PATH"
            ;;
        xfs)
            echo -e "${yellow}[+] Redimensionando el sistema de archivos XFS en $LV_PATH...${end}"
            xfs_growfs "$LV_PATH"
            ;;
        *)
            echo -e "${red}[✗] Tipo de sistema de archivos no compatible: $FS_TYPE${end}"
            ;;
    esac

    echo -e "\n${green}[✔] Proceso finalizado con éxito. La partición ha sido extendida.${end}"
    echo -e "${blue}=============================================================${end}"
    lsblk
    echo -e "${blue}=============================================================${end}"
    read -p "Pulsa ENTER para volver al menú..."
    use_case
}


function crear_particion_extender(){
    clear
    echo -e "${blue}=============================================================${end}"
    echo -e "${green}   ✦ Creación de Partición y Extensión de Volumen LVM ✦${end}"
    echo -e "${blue}=============================================================${end}\n"

    # ** ADVERTENCIA Y CONFIRMACIÓN DEL USUARIO**
    echo -e "${yellow}[⚠] ADVERTENCIA: Se creará la partición ${disk_device}${num_particion}.${end}"
    echo -e "${yellow}Luego, será añadida al grupo de volúmenes ${VG_NAME} y extendida en el volumen lógico ${LV_PATH}.${end}"
    read -p "¿Deseas continuar? (yes/no): " confirmacion
    if [[ "$confirmacion" != "yes" ]]; then
        echo -e "${red}[✗] Operación cancelada.${end}"
        exit 1
    fi

    particion="${disk_device}${num_particion}"
    echo "$num_particion"
    # ** CREAR LA PARTICIÓN**
    echo -e "\n${yellow}[+] Creando partición en ${disk_device}, número: ${num_particion}...${end}"
    fdisk "$disk_device" <<EOF
n
p
$num_particion


t
$num_particion
8e
w
EOF

    # ** FORZAR AL SISTEMA A RECONOCER LA NUEVA PARTICIÓN**
    echo -e "\n${yellow}[+] Actualizando la tabla de particiones...${end}"
    partprobe "$disk_device"
    sleep 2

    # ** VERIFICAR QUE LA PARTICIÓN SE CREÓ CORRECTAMENTE**
    if [[ ! -b "$particion" ]]; then
        echo -e "${red}[✗] Error: No se pudo crear la partición ${particion}.${end}"
        exit 1
    fi

    echo -e "${green}[✔] Partición ${particion} creada correctamente.${end}"

    # ** CREAR VOLUMEN FÍSICO EN LA NUEVA PARTICIÓN**
    echo -e "\n${yellow}[+] Creando volumen físico en ${particion}...${end}"
    pvcreate "$particion"

    # * AÑADIR LA PARTICIÓN AL GRUPO DE VOLÚMENES (VG)**
    echo -e "\n${yellow}[+] Extendiendo el Grupo de Volúmenes ${VG_NAME} con ${particion}...${end}"
    vgextend "$vg_option" "$particion"

    # ** EXTENDER EL VOLUMEN LÓGICO (LV)**
    echo -e "\n${yellow}[+] Extendiendo el Volumen Lógico: ${LV_PATH}...${end}"
    lvextend -l +100%FREE "$LV_PATH"



    # ** REDIMENSIONAR EL SISTEMA DE ARCHIVOS SEGÚN SU TIPO**
    echo -e "\n${blue}[+] Redimensionando el sistema de archivos...${end}"
    case $FS_TYPE in
        ext2|ext3|ext4)
            resize2fs "$LV_PATH"
            echo -e "${green}[✔] Sistema de archivos EXT4 redimensionado correctamente.${end}"
            ;;
        xfs)
            xfs_growfs "$LV_PATH"
            echo -e "${green}[✔] Sistema de archivos XFS redimensionado correctamente.${end}"
            ;;
    esac

    echo -e "\n${green}[✔] Proceso finalizado con éxito. La nueva partición ha sido añadida al LVM.${end}"
    echo -e "${blue}=============================================================${end}"
    lsblk
    echo -e "${blue}=============================================================${end}"
    read -p "Pulsa ENTER para volver al menú..."
    use_case
}

function generar_disco_lvm(){
    clear
    echo -e "${blue}=============================================================${end}"
    echo -e "${green}   ✦ Creación de Disco y Configuración de LVM ✦${end}"
    echo -e "${blue}=============================================================${end}\n"

    # ** CONFIRMACIÓN DEL USUARIO**
    echo -e "${yellow}[⚠] ADVERTENCIA: Se creará una partición en ${disk_device}, se configurará como LVM y será montada en ${MOUNT_POINT}.${end}"
    read -p "¿Deseas continuar? (yes/no): " confirmacion
    if [[ "$confirmacion" != "yes" ]]; then
        echo -e "${red}[✗] Operación cancelada.${end}"
        exit 1
    fi

    # ** VERIFICAR QUE EL DISCO EXISTA**
    if [[ ! -b "$disk_device" ]]; then
        echo -e "${red}[✗] Error: El disco ${disk_device} no existe.${end}"
        exit 1
    fi

    # ** CREAR UNA NUEVA PARTICIÓN CON FDISK**
    echo -e "\n${yellow}[+] Creando partición en $disk_device...${end}"
    (
        echo "n"    # Nueva partición
        echo "p"    # Partición primaria
        echo "1"    # Número de partición (1 en este caso)
        echo ""     # Primer sector (por defecto)
        echo ""     # Último sector (máximo disponible)
        echo "t"    # Cambiar tipo de partición
        echo "8e"   # Tipo LVM
        echo "w"    # Guardar cambios y salir
    ) | fdisk "$disk_device" &> /dev/null

    # ** FORZAR AL SISTEMA A RECONOCER LA NUEVA PARTICIÓN**
    echo -e "\n${yellow}[+] Actualizando la tabla de particiones...${end}"
    partprobe "$disk_device"
    udevadm trigger
    sleep 2

    # ** VERIFICAR QUE LA PARTICIÓN SE CREÓ CORRECTAMENTE**
    particion="${disk_device}1"
    if [[ ! -b "$particion" ]]; then
        echo -e "${red}[✗] Error: No se pudo crear la partición ${particion}.${end}"
        exit 1
    fi
    echo -e "${green}[✔] Partición ${particion} creada correctamente.${end}"

    # ** CREAR VOLUMEN FÍSICO EN LA PARTICIÓN**
    echo -e "\n${yellow}[+] Creando volumen físico en ${particion}...${end}"
    pvcreate "$particion" &> /dev/null
    if [[ $? -ne 0 ]]; then
        echo -e "${red}[✗] Error: No se pudo crear el volumen físico en ${particion}.${end}"
        exit 1
    fi

    # ** CREAR GRUPO DE VOLÚMENES**
    echo -e "\n${yellow}[+] Creando Grupo de Volúmenes $VG_NAME...${end}"
    vgcreate "$VG_NAME" "$particion" &> /dev/null
    if [[ $? -ne 0 ]]; then
        echo -e "${red}[✗] Error: No se pudo crear el Grupo de Volúmenes ${VG_NAME}.${end}"
        exit 1
    fi

    # ** CREAR VOLUMEN LÓGICO CON EL TAMAÑO INDICADO**
    echo -e "\n${yellow}[+] Creando Volumen Lógico $LV_NAME de tamaño $LV_SIZE en $VG_NAME...${end}"
    lvcreate -l 100%FREE -n "$LV_NAME" "$VG_NAME" &> /dev/null
    if [[ $? -ne 0 ]]; then
        echo -e "${red}[✗] Error: No se pudo crear el Volumen Lógico ${LV_NAME}.${end}"
        exit 1
    fi

    # ** OBTENER RUTA COMPLETA DEL VOLUMEN LÓGICO**
    LV_PATH="/dev/$VG_NAME/$LV_NAME"

    # ** FORMATEAR EL VOLUMEN LÓGICO CON EL SISTEMA DE ARCHIVOS SELECCIONADO**
    echo -e "\n${yellow}[+] Formateando $LV_PATH con $FS_TYPE...${end}"
    case $FS_TYPE in
        ext4)
            mkfs.ext4 "$LV_PATH" &> /dev/null
            ;;
        xfs)
            mkfs.xfs "$LV_PATH" &> /dev/null
            ;;
        *)
            echo -e "${red}[✗] Tipo de sistema de archivos no soportado: $FS_TYPE${end}"
            exit 1
            ;;
    esac

    # ** CREAR EL DIRECTORIO DE MONTAJE SI NO EXISTE**
    if [ ! -d "$MOUNT_POINT" ]; then
        echo -e "\n${yellow}[+] Creando el directorio de montaje: $MOUNT_POINT...${end}"
        mkdir -p "$MOUNT_POINT"
    fi

    # ** MONTAR EL VOLUMEN LÓGICO**
    echo -e "\n${yellow}[+] Montando $LV_PATH en $MOUNT_POINT...${end}"
    mount "$LV_PATH" "$MOUNT_POINT"
    if [[ $? -ne 0 ]]; then
        echo -e "${red}[✗] Error: No se pudo montar $LV_PATH en $MOUNT_POINT.${end}"
        exit 1
    fi

    # ** OBTENER UUID DEL LV PARA FSTAB**
    UUID_LV=$(blkid -s UUID -o value "$LV_PATH")

    # ** CONFIGURAR MONTAJE AUTOMÁTICO EN /etc/fstab**
    echo -e "\n${yellow}[+] Configurando montaje automático en /etc/fstab...${end}"
    echo "UUID=$UUID_LV  $MOUNT_POINT  $FS_TYPE  defaults  0  2" | tee -a /etc/fstab

    echo -e "\n${green}[✔] Proceso finalizado con éxito. El disco con LVM ha sido configurado y montado.${end}"
    echo -e "${green}[✔] Para verificar, usa el comando: lsblk o df -h.${end}\n"
     echo -e "${blue}=============================================================${end}"
    lsblk
    echo -e "${blue}=============================================================${end}"
    read -p "Pulsa ENTER para volver al menú..."
    use_case
}
function info_general_caso_uso_1(){
    clear
    echo -e "${blue}=============================================================${end}"
    echo -e "${green}         ✦ Información General para Extender Discos ✦${end}"
    echo -e "${blue}=============================================================${end}\n"

    # Mostrar discos disponibles
    lsblk
    echo -e "\n${yellow}Introduce los nombres de los discos a añadir separados por espacio (Ejemplo: sdb sdc sdd):${end}"
    read -p "Discos: " disco

    # Mostrar identificadores de discos disponibles
    echo -e "\n${yellow}Listado de identificadores de discos disponibles:${end}"
    lsscsi -g
    echo -e "\n${yellow}Introduce los identificadores de los discos seleccionados separados por espacio (Ejemplo: 0:0:0:0 0:0:1:0 0:0:2:0):${end}"
    read -p "Identificadores de discos: " ID_DISK

    # Listar y permitir seleccionar el Grupo de Volúmenes (VG)
    echo -e "\n${yellow}Grupos de volúmenes disponibles:${end}"
    vgs --noheadings -o vg_name | awk '{print NR") " $1}'
    echo -e "\n${yellow}Selecciona el número del Grupo de Volúmenes que deseas usar:${end}"
    read -p "Opción: " vg_option
    

    if [[ -z "$vg_option" ]]; then
        echo -e "${red}[✗] Error: No se seleccionó un Grupo de Volúmenes válido.${end}"
        exit 1
    fi

    echo -e "\n${blue}[+] Grupo de volúmenes seleccionado:${end} ${green}$vg_option${end}\n"

    # Listar y permitir seleccionar el Volumen Lógico (LV)
    echo -e "\n${yellow}Volúmenes Lógicos disponibles en el VG ${vg_option}:${end}"
    lvs --noheadings -o lv_path -S vg_name="$vg_option" | awk '{print NR") " $1}'
    echo -e "\n${yellow}Selecciona el número del Volumen Lógico que deseas extender:${end}"
    read -p "Opción: " LV_PATH
    

    if [[ -z "$LV_PATH" ]]; then
        echo -e "${red}[✗] Error: No se seleccionó un Volumen Lógico válido.${end}"
        exit 1
    fi

    echo -e "\n${blue}[+] Volumen lógico seleccionado:${end} ${green}$LV_PATH${end}\n"

    # Obtener el tipo de sistema de archivos del volumen lógico seleccionado
    FS_TYPE=$(lsblk -no FSTYPE "$LV_PATH" | head -1)
    echo -e "${blue}[+] Sistema de archivos detectado:${end} ${green}$FS_TYPE${end}\n"

    echo -e "${green}✓ Información recopilada correctamente.${end}\n"
    sleep 2
    extender_a_disco  # Llamar a la función para extender el volumen
}


function info_general_caso_uso_2(){
    clear
    echo -e "${blue}=============================================================${end}"
    echo -e "${green}    ✦ Información General para Extender una Partición ✦${end}"
    echo -e "${blue}=============================================================${end}\n"

    # Mostrar discos disponibles
    lsblk
    echo -e "\n${yellow}Introduce el nombre del disco donde se encuentra la partición LVM (Ejemplo: sdb):${end}"
    read -p "Disco: " disco
    disk_device="/dev/$disco"

    # Mostrar particiones del disco seleccionado
    echo -e "\n${yellow}Particiones disponibles en $disk_device:${end}"
    lsblk "$disk_device"
    echo -e "\n${yellow}Introduce el número de la partición a extender (Ejemplo: 1 para /dev/sdb1):${end}"
    read -p "Partición: " particion
    particion="${disk_device}${particion}"

    # Mostrar identificadores de discos disponibles
    echo -e "\n${yellow}Listado de identificadores de discos disponibles:${end}"
    lsscsi -g
    echo -e "\n${yellow}Introduce el identificador del disco seleccionado (Ejemplo: 0:0:0:0):${end}"
    read -p "Identificador de disco: " ID_DISK

    # Mostrar lista de Grupos de Volúmenes disponibles y permitir elegir uno
    echo -e "\n${yellow}Grupos de Volúmenes detectados:${end}"
    vgdisplay --noheadings -C -o vg_name | awk '{print NR") " $1}'
    echo -e "\n${yellow}Introduce el número del Grupo de Volúmenes a utilizar:${end}"
    read -p "Opción: " vg_option
    VG_NAME=$(vgdisplay --noheadings -C -o vg_name | awk "NR==$vg_option {print \$1}")

    echo -e "\n${blue}[+] Grupo de volúmenes seleccionado:${end} ${green}$VG_NAME${end}\n"

    # Mostrar lista de Volúmenes Lógicos dentro del VG seleccionado y permitir elegir uno
    echo -e "\n${yellow}Volúmenes Lógicos detectados en $VG_NAME:${end}"
    lvdisplay | grep "LV Path"
    echo -e "\n${yellow}Introduce el número del Volumen Lógico a utilizar:${end}"
    read -p "Opción: " LV_PATH
    echo -e "\n${blue}[+] Disco seleccionado:${end} ${green}$disco${end}\n"
    echo -e "\n${blue}[+] Particion seleccionada:${end} ${green}$particion${end}\n"
    echo -e "\n${blue}[+] Identificador del disco seleccionado:${end} ${green}$ID_DISK${end}\n"
    echo -e "\n${blue}[+] Grupo de volúmenes seleccionado:${end} ${green}$vg_option${end}\n"
    echo -e "\n${blue}[+] Volumen lógico seleccionado:${end} ${green}$LV_PATH${end}\n"

    # Obtener el sistema de archivos del volumen lógico seleccionado
    FS_TYPE=$(lsblk -no FSTYPE "$LV_PATH" | head -1)
    echo -e "${blue}[+] Sistema de archivos detectado:${end} ${green}$FS_TYPE${end}\n"

    echo -e "${green}✓ Información recopilada correctamente.${end}\n"
    sleep 2
    extender_particion_existente  # Llamar a la función para extender la partición
}
function info_general_caso_uso_3(){
    clear
    echo -e "${blue}=============================================================${end}"
    echo -e "${green}  ✦ Información General para Añadir Partición a LVM ✦${end}"
    echo -e "${blue}=============================================================${end}\n"

    # Mostrar discos disponibles
    lsblk
    echo -e "\n${yellow}Introduce el nombre del disco donde vas a crear la nueva partición (Ejemplo: sdb):${end}"
    read -p "Disco: " disco
    disk_device="/dev/$disco"

    # Mostrar particiones disponibles en el disco
    echo -e "\n${yellow}Particiones disponibles en $disk_device:${end}"
    lsblk -o NAME,SIZE,TYPE,MOUNTPOINT "$disk_device"

    echo -e "\n${yellow}Introduce el número de la partición que quieres crear (Ejemplo: 2 para /dev/sdb2):${end}"
    read -p "Número de partición: " num_particion
    particion="${disk_device}${num_particion}"

    # Mostrar identificadores de discos disponibles
    echo -e "\n${yellow}Listado de identificadores de discos disponibles:${end}"
    lsscsi -g
    echo -e "\n${yellow}Introduce el identificador del disco seleccionado (Ejemplo: 0:0:0:0):${end}"
    read -p "Identificador de disco: " ID_DISK

    # Mostrar lista de Grupos de Volúmenes disponibles y permitir elegir uno
    echo -e "\n${yellow}Grupos de Volúmenes detectados:${end}"
    vgdisplay --noheadings -C -o vg_name | awk '{print NR") " $1}'
    echo -e "\n${yellow}Introduce el número del Grupo de Volúmenes a utilizar:${end}"
    read -p "Opción: " vg_option
    
    # Mostrar lista de Volúmenes Lógicos dentro del VG seleccionado y permitir elegir uno
    echo -e "\n${yellow}Volúmenes Lógicos detectados en $VG_NAME:${end}"
    lvdisplay | grep "LV Path"
    echo -e "\n${yellow}Introduce el número del Volumen Lógico a utilizar:${end}"
    read -p "Opción: " LV_PATH
    echo -e "\n${blue}[+] Disco seleccionado:${end} ${green}$disk_device${end}\n"
    echo -e "\n${blue}[+] Particion seleccionada:${end} ${green}$particion${end}\n"
    echo -e "\n${blue}[+] Identificador del disco seleccionado:${end} ${green}$ID_DISK${end}\n"
    echo -e "\n${blue}[+] Grupo de volúmenes seleccionado:${end} ${green}$vg_option${end}\n"
    echo -e "\n${blue}[+] Volumen lógico seleccionado:${end} ${green}$LV_PATH${end}\n"

    # Obtener el sistema de archivos del volumen lógico seleccionado
    FS_TYPE=$(lsblk -no FSTYPE "$LV_PATH" | head -1)
    echo -e "${blue}[+] Sistema de archivos detectado:${end} ${green}$FS_TYPE${end}\n"

    echo -e "${green}✓ Información recopilada correctamente.${end}\n"
    sleep 2
    crear_particion_extender  # Llamar a la función para extender la partición
}
function info_general_caso_uso_4(){
    clear
    echo -e "${blue}=============================================================${end}"
    echo -e "${green}     ✦ Información General para Crear un Disco con LVM ✦${end}"
    echo -e "${blue}=============================================================${end}\n"

    # Mostrar discos disponibles
    lsblk
    echo -e "\n${yellow}Introduce el nombre del disco donde se creará el LVM (Ejemplo: sdb):${end}"
    read -p "Disco: " disco
    disk_device="/dev/$disco"

    # Mostrar espacio disponible en el disco
    echo -e "\n${yellow}Espacio disponible en $disk_device:${end}"
    lsblk -o NAME,SIZE,TYPE,MOUNTPOINT "$disk_device"

    # Definir el nombre del Grupo de Volúmenes
    echo -e "\n${yellow}Introduce el nombre del Grupo de Volúmenes (Ejemplo: vg_data):${end}"
    read -p "Nombre del VG: " VG_NAME

    # Definir el nombre del Volumen Lógico
    echo -e "\n${yellow}Introduce el nombre del Volumen Lógico (Ejemplo: lv_storage):${end}"
    read -p "Nombre del LV: " LV_NAME

    # Definir el tamaño del Volumen Lógico
    echo -e "\n${yellow}Introduce el tamaño del Volumen Lógico (Ejemplo: 100G, 50G, 200G):${end}"
    read -p "Tamaño: " LV_SIZE

    # Seleccionar el sistema de archivos
    echo -e "\n${yellow}Selecciona el sistema de archivos a utilizar:${end}"
    echo -e "1) ext4"
    echo -e "2) xfs"
    read -p "Opción (1 o 2): " fs_option

    case $fs_option in
        1) FS_TYPE="ext4";;
        2) FS_TYPE="xfs";;
        *) echo -e "${red}Opción no válida. Se usará ext4 por defecto.${end}"; FS_TYPE="ext4";;
    esac

    # Definir el punto de montaje
    echo -e "\n${yellow}Introduce el punto de montaje donde se usará el LVM (Ejemplo: /mnt/storage):${end}"
    read -p "Punto de montaje: " MOUNT_POINT

    echo -e "\n${blue}[+] Información recopilada:${end}"
    echo -e "${green}Disco seleccionado:${end} ${yellow}$disk_device${end}"
    echo -e "${green}Grupo de Volúmenes:${end} ${yellow}$VG_NAME${end}"
    echo -e "${green}Volumen Lógico:${end} ${yellow}$LV_NAME${end}"
    echo -e "${green}Tamaño del LV:${end} ${yellow}$LV_SIZE${end}"
    echo -e "${green}Sistema de archivos:${end} ${yellow}$FS_TYPE${end}"
    echo -e "${green}Punto de montaje:${end} ${yellow}$MOUNT_POINT${end}\n"

    echo -e "${green}✓ Información recopilada correctamente.${end}\n"
    sleep 2
    generar_disco_lvm  # Llamar a la función para crear el LVM desde cero
}
inicio
