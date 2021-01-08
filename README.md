# razor-vanagon

## How to promote to PE

1. Tag razor-server with the correct version (using Kerminator).
1. Pin razor-vanagon to that version in configs/components/razor-server.json. Commit this to master.
1. Tag razor-vanagon with the SHA of the commit above (using Kerminator).

Git automation will generate pe-razor-server packages, then promote those packages into the latest version of PE.

### If the release branch has already been cut

Once the pe-razor-server packages [appear](builds.puppetlabs.lan/pe-razor-server), run the [Package Promotion Job](https://jenkins-compose.delivery.puppetlabs.net/view/Promotion/job/Package-Promotion/build?delay=0sec) using the release branch name as the `BRANCH` parameter.

Verify promotion by issuing `pelist <release_branch_title>` to Kerminator or checking enterprise-dist's commit history for the release branch on GitHub.
