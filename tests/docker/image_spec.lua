--# selene: allow(undefined_variable, incorrect_standard_library_use)

local image = require("hack.docker.image")

context("Docker", function()
  describe("Image", function()
    it("can be created from a docker JSON output", function()
      local json =
        [[{"Containers":"0","CreatedAt":"2025-08-26 22:25:20 +0200 CEST","CreatedSince":"8 months ago","Digest":"\u003cnone\u003e","ID":"fb90a2eb6a79","Repository":"nix","SharedSize":"N/A","Size":"9.75GB","Tag":"test","UniqueSize":"N/A"}]]
      local test_image = image.Image:new_from_docker_json(json)
      assert.are.equal("fb90a2eb6a79", test_image:identity())
      assert.are.equal("2025-08-26", test_image:created_at())
      assert.are.equal("nix:test", test_image:fullname())
    end)
  end)
end)

context("Podman", function()
  describe("Image", function()
    it("can be created from a podman JSON output", function()
      local json = [[{
        "Id": "8a449b5ad73f4321fe6fc09dc612200dcae011e8df332ee7bad0a48e58303310",
        "ParentId": "",
        "RepoTags": null,
        "RepoDigests": [
            "quay.io/keycloak/keycloak@sha256:925e11c01018d3d1ac734fd450307f420887f480c01fe723c361b887113742c7",
            "quay.io/keycloak/keycloak@sha256:be6a86215213145bfb4fb3e2b3ab982a806d00262655abdcf3ffa6a38d241c7c",
            "quay.io/keycloak/keycloak@sha256:dc23dd938a5dc5dfaabc71e44d014928284fafff9122e0395659f1cdcf534da8"
        ],
        "Size": 451127168,
        "SharedSize": 0,
        "VirtualSize": 451127168,
        "Labels": {
            "architecture": "x86_64",
            "build-date": "2025-04-08T13:14:37Z",
            "com.redhat.build-host": "",
            "com.redhat.component": "",
            "com.redhat.license_terms": "",
            "description": "Keycloak Server Image",
            "distribution-scope": "public",
            "io.buildah.version": "1.39.0-dev",
            "io.k8s.description": "Keycloak Server Image",
            "io.k8s.display-name": "Keycloak Server",
            "io.openshift.expose-services": "",
            "io.openshift.tags": "keycloak security identity",
            "maintainer": "https://www.keycloak.org/",
            "name": "keycloak",
            "org.opencontainers.image.created": "2025-04-11T07:58:44.198Z",
            "org.opencontainers.image.description": "",
            "org.opencontainers.image.documentation": "https://www.keycloak.org/documentation",
            "org.opencontainers.image.licenses": "Apache-2.0",
            "org.opencontainers.image.revision": "e7109eeda3e2630bb65640a6a322f0cb6ff6ddd6",
            "org.opencontainers.image.source": "https://github.com/keycloak-rel/keycloak-rel",
            "org.opencontainers.image.title": "keycloak-rel",
            "org.opencontainers.image.url": "https://github.com/keycloak-rel/keycloak-rel",
            "org.opencontainers.image.version": "26.1.5",
            "release": "",
            "summary": "Keycloak Server Image",
            "url": "https://www.keycloak.org/",
            "vcs-ref": "",
            "vcs-type": "git",
            "vendor": "https://www.keycloak.org/",
            "version": "26.1.5"
        },
        "Containers": 0,
        "Digest": "sha256:925e11c01018d3d1ac734fd450307f420887f480c01fe723c361b887113742c7",
        "History": [
            "quay.io/keycloak/keycloak:26.1",
            "quay.io/keycloak/keycloak@sha256:be6a86215213145bfb4fb3e2b3ab982a806d00262655abdcf3ffa6a38d241c7c"
        ],
        "Names": [
            "quay.io/keycloak/keycloak@sha256:be6a86215213145bfb4fb3e2b3ab982a806d00262655abdcf3ffa6a38d241c7c",
            "quay.io/keycloak/keycloak:26.1"
        ],
        "Created": 1744358359,
        "CreatedAt": "2025-04-11T07:59:19Z"
      }]]
      local test_image = image.Image:new_from_podman_json(json)
      assert.are.equal("8a449b5ad73f4321fe6fc09dc612200dcae011e8df332ee7bad0a48e58303310", test_image:identity())
      assert.are.equal("2025-04-11", test_image:created_at())
      assert.are.equal("quay.io/keycloak/keycloak:26.1", test_image:fullname())
    end)
  end)
end)
