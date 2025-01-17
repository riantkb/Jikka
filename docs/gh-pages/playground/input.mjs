import * as rts from "./rts.mjs";
import wasm from "./jikka-asterius.wasm.mjs";
import req from "./jikka-asterius.req.mjs";

async function convert(prog) {
  const m = await wasm;
  const i = await rts.newAsteriusInstance(Object.assign(req, { module: m }));
  return await i.exports.convert(prog);
}

function loadData() {
  const req = new XMLHttpRequest();
  req.open("GET", "../gallery/data.json", false);
  req.send();
  if (req.status != 200) {
    throw Error(req.statusText);
  }
  return JSON.parse(req.responseText);
}

window.addEventListener("DOMContentLoaded", function () {
  require(["vs/editor/editor.main"], function () {
    // make editors
    const input = monaco.editor.create(document.getElementById("input"), {
      value: "loading...",
      language: "python",
    });
    const output = monaco.editor.create(document.getElementById("output"), {
      value: "",
      language: "cpp",
    });

    // transpiling periodically
    let lastValue = "";
    console.log(lastValue);
    const sync = function () {
      try {
        if (input.getValue() == lastValue) {
          setTimeout(sync, 1000);
        } else {
          lastValue = input.getValue();
          output.setValue("transpiling...");
          convert(lastValue).then(function (value) {
            output.setValue(value);
            setTimeout(sync, 1000);
          });
        }
      } catch (e) {
        console.log(e);
        setTimeout(sync, 1000);
      }
    };
    sync();

    // make dropdown menu of examples
    const dropdown = document.getElementById("dropdown");
    function addItem(row) {
      const li = document.createElement("li");
      const a = document.createElement("a");
      a.textContent = row["path"];
      a.classList.add("dropdown-item");
      a.addEventListener("click", function () {
        input.setValue(row["python"]);
      });
      li.appendChild(a);
      dropdown.appendChild(li);
    }
    const data = loadData();
    for (const row of data["examples"]) {
      addItem(row);
      if (row["path"] == "examples/dp_z-kubaru.py") {
        // default
        input.setValue(row["python"]);
      }
    }
    for (const row of data["errors"]) {
      addItem(row);
    }
  });
});
