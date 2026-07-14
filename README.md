<p align="center">
  <h1 align="center"><b>Riggi</b></h1>
  <p align="center">
    Roblox plugin for inserting characters. Currently only works with Perdere character saves.
    <br />
  </p>
</p>

<div align="center">
  <a href="https://github.com/raineyraine/roblox-plugin-riggi/actions/workflows/ci.yaml"><img src="https://img.shields.io/github/actions/workflow/status/raineyraine/roblox-plugin-riggi/ci.yaml?colorA=363a4f&colorB=a6da95&style=for-the-badge&logo=data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAyNTYgMjU2Ij4KPHBhdGggZD0iTTIxNiwzMlYxOTJhOCw4LDAsMCwxLTgsOEg3MmExNiwxNiwwLDAsMC0xNiwxNkgxOTJhOCw4LDAsMCwxLDAsMTZINDhhOCw4LDAsMCwxLTgtOFY1NkEzMiwzMiwwLDAsMSw3MiwyNEgyMDhBOCw4LDAsMCwxLDIxNiwzMloiIHN0eWxlPSJmaWxsOiAjQ0FEM0Y1OyIvPgo8L3N2Zz4="></a>
  <a href="https://github.com/raineyraine/roblox-plugin-riggi/releases/latest"><img src="https://img.shields.io/github/v/release/raineyraine/roblox-plugin-riggi?colorA=363a4f&colorB=a6da95&style=for-the-badge&logo=github&logoColor=cad3f5"></a>
  <a href="https://github.com/raineyraine/roblox-plugin-riggi/issues"><img src="https://img.shields.io/github/issues/raineyraine/roblox-plugin-riggi?colorA=363a4f&colorB=f5a97f&style=for-the-badge&logo=data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAyNTYgMjU2Ij4KPHBhdGggZD0iTTIxNiwzMlYxOTJhOCw4LDAsMCwxLTgsOEg3MmExNiwxNiwwLDAsMC0xNiwxNkgxOTJhOCw4LDAsMCwxLDAsMTZINDhhOCw4LDAsMCwxLTgtOFY1NkEzMiwzMiwwLDAsMSw3MiwyNEgyMDhBOCw4LDAsMCwxLDIxNiwzMloiIHN0eWxlPSJmaWxsOiAjQ0FEM0Y1OyIvPgo8L3N2Zz4="></a>
</div>

## 📦 Installation

### Github Releases

You can install the latest `.rbxm` of the plugin
[here](https://github.com/raineyraine/riggi_plugin/releases/latest). Then, you
will have to add it as a local plugin in studio. Use `Plugins > Plugins Folder`
to find that folder:

![alt text](assets/studio-plugin-folder.png)

You will likely have to reload studio to have it properly install.

### Build Manually

You can also clone the repository and run the `lute build -i` script to build
and install the plugin.

## Usage

The main interface looks like this:

![Riggi user interface](assets/plugin-example.png)

Add outfits (the paste string button does not work and does nothing) with the
**Add outfit** button. This will prompt you to select `.json` or `.txt` files
containing Perdere character saves. You can select these outfits or delete them
in the list, or search your outfits. Outfits should also save between studio
sessions.

Import outfits by pressing **Import selected** (or, if no outfits are selected,
import files with **Import files**). You can set the material of accessories
using the **Material** dropdown. There are two special materials, `Original`,
which preserves the saved material (may make textureless accessories have the
`Plastic` texture), or `EntirelyBlankPlastic`, which is SmoothPlastic but
without extreme reflections. For `EntirelyBlankPlastic`, ensure you click
**Setup material variant**.

> [!NOTE]  
> If an accessory's texture is `rbxassetid://0` or `rbxassetid://1`, its
> MeshPart texture will be blank. This is done to preserve ingame appearance.

## 🗒️ License

[raineyraine/roblox-plugin-riggi](https://github.com/raineyraine/roblox-plugin-riggi)
is licensed under the
[MIT License](https://github.com/raineyraine/roblox-plugin-riggi/blob/main/LICENSE).

## 👥 Attribution

- [alicesaidhi/videkit_ty](https://github.com/alicesaidhi/videkit_ty/) MIT
  License\
  Used for plugin UI. Code is modified, since videkit_ty is not updated and
  doesn't work well with modern Vide and Luau.
- [centau/vide](https://github.com/centau/vide) MIT License\
  Used for plugin UI, core functionality, and state.
