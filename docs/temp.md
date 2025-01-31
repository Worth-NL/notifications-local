# Temporary measures

> [!TIP]
> These are also things that could either be documented better or automated.

## Post-setup

After being able to successfully run the environment via `tilt up`, some extra steps are still required to have a smooth experience.

### Database tweaks

Some modifications need to be done to the database in order to avoid issues with Firetext and ensure texts/emails can be sent.

Connect to the now-running database via whichever client you like ([can be done via VSCode as described in the recommended extensions section](vscode.md#recommended-extensions)).

Run the queries listed in the [dbfix.sql](../scripts/dbfix.sql) file.