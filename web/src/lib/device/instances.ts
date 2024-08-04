import {loginQueries} from '$lib/data/instances'
import ActivationPool from '$lib/device/ActivationPool'

export const activationPool = new ActivationPool(loginQueries)
