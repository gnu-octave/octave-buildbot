# https://docs.buildbot.net/current/manual/customization.html#writing-dashboards-with-flask-or-bottle

import os
import time
import pprint

from collections import defaultdict

from flask import Flask
from flask import render_template

from buildbot.process.results import statusToString

def fmtDate(e):
    """Format epoch to string."""
    return time.strftime("%a, %Y %b %d %H:%M:%S %z", time.gmtime(e))

def categorizeFiles(files):
    """Categorize list of filenames."""
    nested_dict = lambda: defaultdict(nested_dict)
    files_sorted = nested_dict()
    for f in files:
      _, ext = os.path.splitext(f)
      ext = ext[1:]
      if "doxyhtml.zip" in f:
        files_sorted["doxygen"].setdefault(ext, []).append(f)
      elif "doxyhtml" in f:
        files_sorted["doxygen"].setdefault("html", []).append(f)
      elif "interpreter.zip" in f:
        files_sorted["manual"].setdefault(ext, []).append(f)
      elif "octave.html" in f:
        files_sorted["manual"].setdefault(ext, []).append(f)
      elif "octave.pdf" in f:
        files_sorted["manual"].setdefault(ext, []).append(f)
      elif "-w32" in f and "log-" in f:
        files_sorted["octave-mxe"]["w32"].setdefault("log", []).append(f)
      elif "-w64-64" in f and "log-" in f:
        files_sorted["octave-mxe"]["w64-64"].setdefault("log", []).append(f)
      elif "-w64" in f and "log-" in f:
        files_sorted["octave-mxe"]["w64"].setdefault("log", []).append(f)
      elif "-w32" in f:
        files_sorted["octave-mxe"]["w32"].setdefault(ext, []).append(f)
      elif "-w64-64" in f:
        files_sorted["octave-mxe"]["w64-64"].setdefault(ext, []).append(f)
      elif "-w64" in f:
        files_sorted["octave-mxe"]["w64"].setdefault(ext, []).append(f)
      elif "octave-" in f and ".tar." in f:
        files_sorted["octave"].setdefault('tar.' + ext, []).append(f)
      else:
        files_sorted.setdefault("unknown", []).append(f)
    return files_sorted

octavedownloadapp = Flask(__name__,
                          root_path = os.path.dirname(__file__),
                          template_folder = "",
                          static_folder = "")

@octavedownloadapp.route("/index.html")
def main():
  config = {}
  # Absolute directory, where stable Octave builds are stored on the master.
  config["stable_dir"] = "/buildbot/data/stable"
  # URL, where stable Octave builds are visible to the public.
  config["data_url"] = octavedownloadapp.config["DATA_DIR_URL"] + "/data/stable"
  # Repository from which Octave is built.
  config["repo_url"] = octavedownloadapp.config["OCTAVE_HG_REPO_URL"]
  # URL-prefix to changes in the repository from which Octave is built.
  config["repo_change_url"] = config["repo_url"] + "/rev"

  # Create directory list with file and metadata.
  builds = []
  if os.path.isdir(config["stable_dir"]):
    with os.scandir(config["stable_dir"]) as entries:
      for entry in entries:
        if entry.is_dir():
          entry_ctime = os.path.getctime(entry)
          files = categorizeFiles(os.listdir(config["stable_dir"] + '/' +
                                             entry.name))
          try:
            version = files["octave"]["tar.gz"][0][7:-7]  # octave-VERSION.tar.gz
          except:
            version = "unknown"
          builds.append({
            "id": entry.name,
            "version": version,
            "sort": entry_ctime,
            "date": fmtDate(entry_ctime),
            "files": files
          })

  # Order by newest build first.
  builds = sorted(builds, key = lambda i: i["sort"], reverse=True)

  # This code fetches build data from the data api, and gives it to the
  # template.
  #builders = octavedownloadapp.buildbot_api.dataGet("/builders")
  #builds   = octavedownloadapp.buildbot_api.dataGet("/builds", limit=20)
  # Properties are actually not used in the template example, but this is
  # how you get more properties
  #for build in builds:
  #    build['properties'] = octavedownloadapp.buildbot_api.dataGet(
  #      ("builds", build['buildid'], "properties"))
  #    build['results_text'] = statusToString(build['results'])

  return render_template("octave_download_app.html",
                         builds = builds,
                         config = config)
