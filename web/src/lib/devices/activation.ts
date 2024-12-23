import {loginQueries} from '$lib/data/queries'
import ActivationPool from './ActivationPool'

export const activationPool = new ActivationPool(loginQueries)
