#!/usr/bin/env node
import { execSync, spawnSync } from "node:child_process";

const log = (message) => {
  console.log(`\n[firefly-sync] ${message}`);
};

const runAndCapture = (command) => {
  try {
    return execSync(command, { stdio: "pipe", encoding: "utf-8" }).trim();
  } catch (error) {
    throw new Error(`Failed to run \`${command}\`\n${error.message}`);
  }
};

const runStreaming = (command) => {
  const result = spawnSync(command, {
    stdio: "inherit",
    shell: true,
  });

  if (result.status !== 0) {
    const error = new Error(`Command failed: ${command}`);
    error.exitCode = result.status ?? 1;
    throw error;
  }
};

const ensureInsideGitRepo = () => {
  runAndCapture("git rev-parse --is-inside-work-tree");
};

const ensureRemoteExists = (remoteName) => {
  const remotes = runAndCapture("git remote").split(/\s+/).filter(Boolean);
  if (!remotes.includes(remoteName)) {
    throw new Error(
      `Missing remote \"${remoteName}\". Run: git remote add ${remoteName} https://github.com/CuteLeaf/Firefly.git`
    );
  }
};

const ensureCleanWorkingTree = () => {
  const status = runAndCapture("git status --porcelain");
  if (status.length > 0) {
    throw new Error(
      "Working tree is dirty. Please commit or stash changes before syncing the template."
    );
  }
};

const getCurrentBranch = () => {
  const branch = runAndCapture("git rev-parse --abbrev-ref HEAD");
  if (branch === "HEAD") {
    throw new Error(
      "Detached HEAD state detected. Checkout the branch you want to update before syncing."
    );
  }
  return branch;
};

const getUpstreamHeadBranch = () => {
  const remoteInfo = runAndCapture("git remote show upstream");
  const match = remoteInfo.match(/HEAD branch:\s+([^\n]+)/);
  if (match && match[1]) {
    return match[1].trim();
  }
  throw new Error(
    "Unable to detect upstream default branch. Ensure the upstream remote is healthy."
  );
};

const updateSyncBranch = (upstreamBranch) => {
  log(`Updating local tracking branch for upstream (${upstreamBranch}).`);
  runStreaming(`git branch --force upstream-sync upstream/${upstreamBranch}`);
};

const mergeSyncBranch = (currentBranch) => {
  log(`Merging upstream changes into ${currentBranch}.`);
  try {
    runStreaming("git merge upstream-sync");
  } catch (error) {
    console.error(
      '\nMerge conflicts detected. Resolve them, then run `git merge --continue`.\nIf you prefer to abort, run `git merge --abort`.\nRefer to docs/upstream-sync.md for detailed steps.'
    );
    throw error;
  }
};

const main = () => {
  try {
    ensureInsideGitRepo();
    ensureRemoteExists("upstream");
    ensureCleanWorkingTree();

    const currentBranch = getCurrentBranch();

    log("Fetching upstream...");
    runStreaming("git fetch upstream --tags --prune");

    const upstreamBranch = getUpstreamHeadBranch();
    updateSyncBranch(upstreamBranch);
    mergeSyncBranch(currentBranch);

    log(
      `Sync complete! Review the merge result and push your branch when you're satisfied.`
    );
  } catch (error) {
    console.error(`\n[firefly-sync] ${error.message}`);
    process.exit(error.exitCode ?? 1);
  }
};

main();
