# https://docs.buildbot.net/current/manual/customization.html#writing-dashboards-with-flask-or-bottle

import os
import time

from flask import Flask
from flask import render_template

from buildbot.process.results import statusToString

octavedownloadapp = Flask(__name__,
                          root_path = os.path.dirname(__file__))

# This allows to work on the template without having to restart Buildbot.
octavedownloadapp.config["TEMPLATES_AUTO_RELOAD"] = True


@octavedownloadapp.route("/index.html")
def main():
  # This code fetches build data from the data api, and gives it to the
  # template.
  builders = octavedownloadapp.buildbot_api.dataGet("/builders")
  builds   = octavedownloadapp.buildbot_api.dataGet("/builds", limit=20)

  # Absolute directory, where stable Octave builds are stored.
  oct_stable_dir = "/buildbot/data/stable"
  oct_stable_url = octavedownloadapp.config["DATA_DIR_URL"] + "/data/stable"

  # Create list of directory names with time stamps.
  oct_build_id_dirs = []
  with os.scandir(oct_stable_dir) as it:
    for entry in it:
      if entry.is_dir():
        oct_build_id_dirs.append({
          "name": entry.name,
          "sort": os.path.getctime(entry),
          "date": []
        })
        oct_build_id_dirs[-1]["date"] = time.strftime(
          "%a, %Y %b %d %H:%M:%S %z",
          time.gmtime(oct_build_id_dirs[-1]["sort"]))
  # Ordered by newest directory first.
  oct_build_id_dirs = sorted(oct_build_id_dirs, key = lambda i: i["sort"], reverse=True)

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
                         oct_stable_url = oct_stable_url)

@octavedownloadapp.route("/data")
def main2():
  return "Hi data"
