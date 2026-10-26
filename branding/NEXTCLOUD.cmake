# SPDX-FileCopyrightText: 2017 Nextcloud GmbH and Nextcloud contributors
# SPDX-FileCopyrightText: 2012 ownCloud GmbH
# SPDX-FileCopyrightText: 2026 OpenSys
# SPDX-License-Identifier: GPL-2.0-or-later
#
# OpenDrive branding. Replaces NEXTCLOUD.cmake of nextcloud/desktop (see UPSTREAM).
# APPLICATION_SHORTNAME is the credential prefix and the config folder name; changing it
# after release orphans accounts written by OpenSysID.DeviceAgent (ADR-0077).
set( APPLICATION_NAME       "OpenDrive" )
set( APPLICATION_SHORTNAME  "OpenDrive" )
set( APPLICATION_EXECUTABLE "opendrive" )
set( APPLICATION_ICON_NAME  "OpenDrive" )

set( APPLICATION_CONFIG_NAME "${APPLICATION_EXECUTABLE}" )
set( APPLICATION_DOMAIN     "opensysid.com" )
set( APPLICATION_VENDOR     "OpenSys" )
# Must not be empty: theme.cpp uses it even without the updater (BUILD_UPDATER OFF, never called).
set( APPLICATION_UPDATE_URL "https://files.opensysid.com/" CACHE STRING "URL for updater" )
set( APPLICATION_HELP_URL   "https://files.opensysid.com/" CACHE STRING "URL for the help menu" )

set( APPLICATION_ICON_SET   "SVG" )
set( APPLICATION_SERVER_URL "https://files.opensysid.com" CACHE STRING "URL for the server to use. If entered, the UI field will be pre-filled with it" )
set( APPLICATION_SERVER_URL_ENFORCE ON )
set( APPLICATION_REV_DOMAIN "com.opensysid.opendrive" )
set( APPLICATION_REV_DOMAIN_DBUS "opendrive.opensysid.com" )
set( DEVELOPMENT_TEAM "" CACHE STRING "Apple Development Team ID" )
set( APPLICATION_VIRTUALFILE_SUFFIX "opendrive" CACHE STRING "Virtual file suffix (not including the .)")
set( APPLICATION_OCSP_STAPLING_ENABLED OFF )
set( APPLICATION_FORBID_BAD_SSL ON )

set( LINUX_PACKAGE_SHORTNAME "opendrive" )
set( LINUX_APPLICATION_ID "${APPLICATION_REV_DOMAIN}.${LINUX_PACKAGE_SHORTNAME}")

set( THEME_CLASS            "NextcloudTheme" )
set( WIN_SETUP_BITMAP_PATH  "${CMAKE_SOURCE_DIR}/admin/win/nsi" )

set( MAC_INSTALLER_BACKGROUND_FILE "${CMAKE_SOURCE_DIR}/admin/osx/installer-background.png" CACHE STRING "The MacOSX installer background image")

## Updater options
option( BUILD_UPDATER "Build updater" OFF )

option( WITH_PROVIDERS "Build with providers list" OFF )

option( ENFORCE_VIRTUAL_FILES_SYNC_FOLDER "Enforce use of virtual files sync folder when available" ON )
option( DISABLE_VIRTUAL_FILES_SYNC_FOLDER "Disable use of virtual files sync folder even when available" OFF )

option(ENFORCE_SINGLE_ACCOUNT "Enforce use of a single account in desktop client" ON)

option( DO_NOT_USE_PROXY "Do not use system wide proxy, instead always do a direct connection to server" OFF )

option( WIN_DISABLE_USERNAME_PREFILL "Do not prefill the Windows user name when creating a new account" ON )

# A Nextcloud client on the same station must not be imported into OpenDrive.
option( APPLICATION_DISPLAY_LEGACY_IMPORT_DIALOG "Display legacy import dialog" OFF )
option( DISABLE_ACCOUNT_MIGRATION "Exclude legacy account migration and import" ON )

## Theming options
set(NEXTCLOUD_BACKGROUND_COLOR "#5B21B6" CACHE STRING "Default background color")
set( APPLICATION_WIZARD_HEADER_BACKGROUND_COLOR "#FFFFFF" CACHE STRING "Hex color of the wizard header background")
set( APPLICATION_WIZARD_HEADER_TITLE_COLOR "#5B21B6" CACHE STRING "Hex color of the text in the wizard header")
option( APPLICATION_WIZARD_USE_CUSTOM_LOGO "Use the logo from ':/client/theme/colored/wizard_logo.(png|svg)' else the default application icon is used" ON )

## Windows Shell Extensions & MSI: GUIDs of our own, never the Nextcloud ones,
## so OpenDrive and a Nextcloud client can coexist on one station.
if(WIN32)
    set( WIN_SHELLEXT_CONTEXT_MENU_GUID      "{C2C55A84-63A9-4331-A4EB-709BD8FD61BF}" )

    set( WIN_SHELLEXT_OVERLAY_GUID_ERROR     "{E9DE80E9-92C3-4E20-A562-74EBE9DDBB51}" )
    set( WIN_SHELLEXT_OVERLAY_GUID_OK        "{1190528C-AE66-4123-BC44-B78C0BD9399E}" )
    set( WIN_SHELLEXT_OVERLAY_GUID_OK_SHARED "{F114A50F-B44C-4D65-929D-C24C45B1B6C7}" )
    set( WIN_SHELLEXT_OVERLAY_GUID_SYNC      "{D2D32D47-3238-4916-B34C-85818C82FD0A}" )
    set( WIN_SHELLEXT_OVERLAY_GUID_WARNING   "{E0987F5E-B668-4F06-8189-C1F2F40DD270}" )

    # MSI Upgrade Code (without brackets). Fixed for the life of the product.
    set( WIN_MSI_UPGRADE_CODE                "56D0FB96-69C2-43C9-8D02-E2C0DD342767" )

    option( BUILD_WIN_MSI "Build MSI scripts and helper DLL" ON )
    option( BUILD_WIN_TOOLS "Build Win32 migration tools" OFF )
endif()
