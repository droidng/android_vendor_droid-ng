/**
 * Copyright (c) 2016 The CyanogenMod Project
 *               2018-2021 The LineageOS Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package org.eu.droid_ng.internal.logging;

import com.android.internal.logging.MetricsLogger;

/**
 * Serves as a central location for logging constants that is android release agnostic.
 */
public class NgMetricsLogger extends MetricsLogger {
    private static final int BASE = -Integer.MAX_VALUE;
    //Since we never want to collide, lets start at the back and move inward
    public static final int DONT_LOG = BASE + 1;

}
