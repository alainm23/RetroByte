project('com.github.alainm23.retro-byte',
        'vala', 'c',
        version: '0.1')

gnome = import('gnome')
i18n = import('i18n')

retro_demo_c_args = [
  '-DRETRO_GTK_USE_UNSTABLE_API',
]

valac = meson.get_compiler ('vala')

asresources = gnome.compile_resources (
    'as-resources', 'data/' + meson.project_name () + '.gresource.xml',
    source_dir: 'data',
    c_name: 'as'
)

add_project_arguments('-DGETTEXT_PACKAGE="@0@"'.format(meson.project_name()), language: 'c')
add_project_arguments('-DLIBICAL_GLIB_UNSTABLE_API=1', language: 'c')

executable(
    meson.project_name (),
    asresources,
    'src/Application.vala',
    'src/MainWindow.vala',
    'src/Utils.vala',

    'src/Services/Database.vala',
    'src/Services/RetroCoreManager.vala',
    'src/Services/SnapshotManager.vala',

    'src/Widgets/HeaderBar.vala',
    'src/Widgets/Pane.vala',
    'src/Widgets/ActionRow.vala',
    'src/Widgets/ConsoleRow.vala',
    'src/Widgets/GameChild.vala',

    'src/Views/CoreView.vala',
    'src/Views/Platform.vala',

    'src/Objects/Game.vala',
    'src/Objects/Snapshot.vala',
    'src/Objects/Platform.vala',
    c_args: retro_demo_c_args,
    dependencies: [
        dependency ('gee-0.8'),
        dependency ('gobject-2.0'),
        dependency ('glib-2.0'),
        dependency ('granite'),
        dependency ('sqlite3'),
        dependency ('gtk+-3.0'),
        dependency ('retro-gtk-1'),
        dependency ('json-glib-1.0'),
        dependency ('libsoup-2.4'),
        dependency ('libhandy-1', version: '>=0.90.0'),
    ],
    gui_app: true,
    install: true
)

subdir('data')
meson.add_install_script('build-aux/meson/post_install.py')