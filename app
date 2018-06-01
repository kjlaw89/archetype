#!/bin/bash

arg=$1

function initialize {
    meson build --prefix=/usr
    result=$?

    if [ $result -gt 0 ]; then
        echo "Unable to initialize, please review log"
        exit 1
    fi

    cd build

    ninja

    result=$?

    if [ $result -gt 0 ]; then
        echo "Unable to build project, please review log"
        exit 2
    fi
}

case $1 in
"clean")
    sudo rm -rf ./build
    ;;
"generate-i18n")
    initialize
    ninja com.github.kjlaw89.archetype-pot
    ninja com.github.kjlaw89.archetype-update-po
    ;;
"install")
    initialize
    sudo ninja install
    ;;
"install-deps")
    output=$((dpkg-checkbuilddeps ) 2>&1)
    result=$?

    if [ $result -eq 0 ]; then
        echo "All dependencies are installed"
        exit 0
    fi

    replace="sudo apt install"
    missing=${output/dpkg-checkbuilddeps: error: Unmet build dependencies:/$replace}
    
    $missing
    ;;
"run")
    initialize
    ./com.github.kjlaw89.archetype
    ;;
"test")
    initialize
    ninja test
    ;;
"test-run")
    initialize
    ninja test

    result=$?

    if [ $result -gt 0 ]; then
        echo "Project built but tests failed"
        exit 100
    fi

    ./com.github.kjlaw89.archetype
    ;;
"uninstall")
    initialize
    sudo ninja uninstall
    ;;
*)
    echo "Usage:"
    echo "  ./app [OPTION]"
    echo ""
    echo "Options:"
    echo "  clean             Removes build directories (can require sudo)"
    echo "  generate-i18n     Generates .pot and .po files for i18n (multi-language support)"
    echo "  install           Builds and installs application to the system (requires sudo)"
    echo "  install-deps      Installs missing build dependencies"
    echo "  run               Builds and runs the application"
    echo "  test              Builds and runs testing for the application"
    echo "  test-run          Builds application, runs testing and if successful application is started"
    echo "  uninstall         Removes the application from the system (requires sudo)"
    ;;
esac
