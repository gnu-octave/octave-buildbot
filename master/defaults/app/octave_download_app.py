# https://docs.buildbot.net/current/manual/customization.html#writing-dashboards-with-flask-or-bottle

import os
import time

from flask import Flask
from flask import render_template

from buildbot.process.results import statusToString

octavedownloadapp = Flask(__name__,
                          root_path = os.path.dirname(__file__),
                          template_folder = "",
                          static_folder = "")

@octavedownloadapp.route("/index.html")
def main():
  # This code fetches build data from the data api, and gives it to the
  # template.
  builders = octavedownloadapp.buildbot_api.dataGet("/builders")
  builds   = octavedownloadapp.buildbot_api.dataGet("/builds", limit=20)

  # Absolute directory, where stable Octave builds are stored.
  oct_stable_dir = "/buildbot/data/stable"
  oct_stable_url = octavedownloadapp.config["DATA_DIR_URL"] + "/data/stable"
  oct_repo_url = octavedownloadapp.config["OCTAVE_HG_REPO_URL"]

  # Create list of directory names with time stamps.
  oct_build_id_dirs = []
  if os.path.isdir(oct_stable_dir):
    with os.scandir(oct_stable_dir) as it:
      for entry in it:
        if entry.is_dir():
          oct_build_id_dirs.append({
            "name": entry.name,
            "version": [],
            "sort": os.path.getctime(entry),
            "date": [],
            "files": []
          })
          oct_build_id_dirs[-1]["date"] = time.strftime(
            "%a, %Y %b %d %H:%M:%S %z",
            time.gmtime(oct_build_id_dirs[-1]["sort"]))
  # Ordered by newest directory first.
  oct_build_id_dirs = sorted(oct_build_id_dirs, key = lambda i: i["sort"], reverse=True)

  # Fetch list of files for each build
  if os.path.isdir(oct_stable_dir):
    for idx, entry in enumerate(oct_build_id_dirs):
      files = os.listdir(oct_stable_dir + '/' + entry["name"])
      version = files[[idx for idx, s in enumerate(files)
                       if 'octave-' in s and '.tar.gz' in s][0]]
      oct_build_id_dirs[idx]["files"] = files
      oct_build_id_dirs[idx]["version"] = version[7:-7]  # octave-VERSION.tar.gz

  # Properties are actually not used in the template example, but this is
  # how you get more properties
  for build in builds:
      build['properties'] = octavedownloadapp.buildbot_api.dataGet(
        ("builds", build['buildid'], "properties"))
      build['results_text'] = statusToString(build['results'])

  # octave_download_app.html is a template inside the template directory.
  return render_template("octave_download_app.html",
                         builders = builders,
                         builds = builds,
                         oct_build_id_dirs = oct_build_id_dirs,
                         oct_stable_url = oct_stable_url,
                         oct_repo_url = oct_repo_url)
