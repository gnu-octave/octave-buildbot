# https://docs.buildbot.net/current/manual/customization.html#writing-dashboards-with-flask-or-bottle

import os
import time

from collections import defaultdict

from flask import Flask
from flask import render_template

from buildbot.process.results import statusToString

def getBuildBotData():
    """Fetches build data from the data api"""
    builds = octavedownloadapp.buildbot_api.dataGet("/builds",
                                                    order=["-started_at"],
                                                    limit=100)
    builds_by_id = {}
    for item in builds:
      item["properties"] = octavedownloadapp.buildbot_api.dataGet(
        ("builds", item["buildid"], "properties"))
      item["results_text"] = statusToString(item["results"])
      if "OCTAVE_BUILD_ID" in item["properties"].keys():
        builds_by_id.setdefault(item["properties"]["OCTAVE_BUILD_ID"][0],
                                []).append(item)
    return builds_by_id

def fmtDate(e):
    """Format epoch to string."""
    return time.strftime("%a, %b %d, %Y", time.gmtime(e))

def fmtSize(byte):
    if byte >= 2**20:
      byte //= 2**20
      suffix = "MB"
    elif byte >= 2**10:
      byte //= 2**10
      suffix = "KB"
    else:
      suffix = "B"
    return f'{byte} {suffix}'

def getFileData(path):
    """Make list of dict from list of valid path."""
    files = []
    for f in os.listdir(path):
      files.append({
        "name": f,
        "size": fmtSize(os.path.getsize(path + '/' + f))
        })
    return files

def categorizeFiles(files):
    """Categorize list of valid file dict {"name", "size"}."""
    nested_dict = lambda: defaultdict(nested_dict)
    files_sorted = nested_dict()
    for f in files:
      filename = f["name"]
      _, ext = os.path.splitext(filename)
      ext = ext[1:]
      if "interpreter.zip" in filename:
        files_sorted["manual"].setdefault(ext, []).append(f)
      elif "octave.html" in filename:
        files_sorted["manual"].setdefault(ext, []).append(f)
      elif "octave.pdf" in filename:
        files_sorted["manual"].setdefault(ext, []).append(f)
      elif "-w32" in filename and "log-" in filename:
        files_sorted["octave-mxe"]["w32"].setdefault("log", []).append(f)
      elif "-w64-64" in filename and "log-" in filename:
        files_sorted["octave-mxe"]["w64-64"].setdefault("log", []).append(f)
      elif "-default-w64" in filename and "log-" in filename:
        files_sorted["octave-mxe"]["mxe-default"].setdefault("log", []).append(f)
      elif "-w64" in filename and "log-" in filename:
        files_sorted["octave-mxe"]["w64"].setdefault("log", []).append(f)
      elif "-w32" in filename:
        files_sorted["octave-mxe"]["w32"].setdefault(ext, []).append(f)
      elif "-w64-64" in filename:
        files_sorted["octave-mxe"]["w64-64"].setdefault(ext, []).append(f)
      elif "-default-w64" in filename:
        files_sorted["octave-mxe"]["mxe-default"].setdefault(ext, []).append(f)
      elif "-w64" in filename:
        files_sorted["octave-mxe"]["w64"].setdefault(ext, []).append(f)
      elif "octave-" in filename and ".tar." in filename:
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
  # Absolute directory, where Octave builds are stored on the master.
  config["data_dir"] = octavedownloadapp.config["DATA_DIR"]
  # URL, where Octave builds are visible to the public.
  config["data_url"] = octavedownloadapp.config["DATA_URL"]
  # Repository from which Octave is built.
  config["repo_url"] = octavedownloadapp.config["OCTAVE_HG_REPO_URL"]
  # URL-prefix to changes in the repository from which Octave is built.
  config["repo_change_url"] = octavedownloadapp.config["OCTAVE_HG_REPO_CHANGE_URL"]

  buildbot_data = getBuildBotData()

  # Create directory list with file and metadata.
  builds = []
  if os.path.isdir(config["data_dir"]):
    with os.scandir(config["data_dir"]) as entries:
      for entry in entries:
        if entry.is_dir():
          if entry.name in buildbot_data.keys():
            build_data = buildbot_data[entry.name]
            try:
              entry_date = build_data[-1]["started_at"].timestamp()
            except:
              entry_date = os.path.getctime(entry)
          else:
            build_data = []
            entry_date = os.path.getctime(entry)
          builds.append({
            "id": entry.name,
            "sort": entry_date,
            "date": fmtDate(entry_date),
            "files": categorizeFiles(getFileData(entry.path)),
            "builds": build_data
          })

  # Order by newest build first.
  builds = sorted(builds, key = lambda i: i["sort"], reverse=True)

  return render_template("octave_download_app.html",
                         builds = builds,
                         config = config)
