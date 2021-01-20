/**
 * Copyright 2020 The AMP HTML Authors. All Rights Reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS-IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
'use strict';

/**
 * @fileoverview
 * This script runs performance tests.
 * This is run during the CI stage = experiment; job = performance tests.
 */

const {
  downloadNomoduleOutput,
  startTimer,
  stopTimer,
  timedExecOrDie,
} = require('./utils');
const {setLoggingPrefix} = require('../common/logging');

const jobName = 'performance-tests.js';

async function main() {
  setLoggingPrefix(jobName);
  const startTime = startTimer(jobName);

  downloadNomoduleOutput(jobName);
  timedExecOrDie('gulp update-packages');
  timedExecOrDie('gulp performance --nobuild --quiet --headless');

  stopTimer(jobName, startTime);
}

main();
