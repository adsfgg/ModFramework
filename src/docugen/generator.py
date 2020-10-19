from datetime import date
from .database import connect_to_database
from .file_scanner import scan_for_docugen_files
from .verbose import verbose_print
from . import markdown_generator
from . import changelog

def find_last_mod_version(c, modVersion):
    version = c.execute(''' SELECT modVersion 
                            FROM FullChangeLog
                            WHERE modVersion <> ?
                            ORDER BY modVersion DESC
                            LIMIT 1''', [modVersion]).fetchone()

    if version == None:
        return 0

    return int(version[0])

def generate_change_logs(args):
    conn, c = connect_to_database()
    vanilla_version = args.vanilla_version
    mod_version = args.mod_version
    prev_mod_version = None

    if args.prev_mod_version:
        prev_mod_version = args.prev_mod_version
    else:
        prev_mod_version = find_last_mod_version(c, mod_version)

    verbose_print("Starting docugen for {}".format("%__MODNAME__%"))
    verbose_print("Vanilla Version: {}".format(vanilla_version))
    verbose_print("Mod Version: {}".format(mod_version))
    verbose_print("Old Mod Version: {}".format(prev_mod_version))

    # Populate database for new version
    scan_for_docugen_files(conn, c, mod_version)

    # Generate full changelog
    create_changelog_against_vanilla(conn, c, vanilla_version, mod_version)

    # Generate partial changelog
    create_changelog_stub(conn, c, mod_version, prev_mod_version)

def create_changelog_against_vanilla(conn, c, vanilla_version, mod_version):
    # Get changelog for version
    raw_changelog = c.execute('''SELECT key,value
                                 FROM FullChangelog
                                 WHERE modVersion = ?
                                 ORDER BY key ASC''', [mod_version]).fetchall()
    
    # Create tree from table
    tree = changelog.ChangeLogTree(raw_changelog)

    # Generate markdown text and write to changelog file
    with open("docs/changelog.md", "w+") as f:
        f.write("# Changes between [{0} revision {1}](revisions/revision{1}.md) and Vanilla Build {2}\n".format("%__MODNAME__%", mod_version, vanilla_version))
        f.write("<br/>\n")
        f.write("\n")
        markdown_generator.generate(f, tree.root_node)

def create_changelog_stub(conn, c, mod_version, prev_mod_version):
    # Get changelog for current version
    current_changelog = c.execute('''SELECT key,value
                                     FROM FullChangelog
                                     WHERE modVersion = ?
                                     ORDER BY key ASC''', [mod_version]).fetchall()
    
    prev_changelog = c.execute('''SELECT key,value
                                 FROM FullChangelog
                                 WHERE modVersion = ?
                                 ORDER BY key ASC''', [prev_mod_version]).fetchall()

    # Diff both changelogs
    diff = changelog.diff(current_changelog, prev_changelog)

    # Create tree from diff
    tree = changelog.ChangeLogTree(diff)

    # Write generated markdown to file
    with open("docs/revisions/revision{}.md".format(mod_version), "w+") as f:
        f.write("# {} revision {} - ({})\n".format("%__MODNAME__%", mod_version, date.today().strftime("%d/%m/%Y")))
        if len(diff) > 0:
            markdown_generator.generate_partial(f, tree.root_node)
        else:
            f.write("\n* No changes for this revision")
        f.write("\n<br/>\n\n")

        if prev_mod_version > 0:
            f.write("[[< prev]](revision{}.md)   Revision {}   [next >]".format(prev_mod_version, mod_version))

            # Update next link in prev version
            lines = None
            with open("docs/revisions/revision{}.md".format(prev_mod_version), "r") as f:
                lines = f.readlines()
            
            new_last_line = lines[-1][:-8] + "[[next >]](revision{}.md)".format(mod_version)
            lines[-1] = new_last_line

            with open("docs/revisions/revision{}.md".format(prev_mod_version), "w") as f:
                f.writelines(lines)
        else:
            f.write("[< prev]   Revision {}   [next >]".format(mod_version))
        