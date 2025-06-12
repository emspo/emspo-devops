const http = require('http');
const { exec } = require('child_process');

const PORT = 8888;
const VALID_TOKEN = 'VALID_DOCKER_TOKEN';
const VALID_USER = 'VALID_DOCKER_USER';
const LOCK_TTL_MS = 10 * 1000; // 10 seconds lock period

const IMAGE_PREFIX_MAP = {
        fe: 'mspots_fe',
        be: 'mspots_be'
};

const folderMap = {
        be: 'mspo/be',
        fe: 'mspo/fe'
}


// Lock and rerun tracking per tag
const locks = new Map()
const rerunScheduled = new Map()

function gitPullForDevelopment(type, callback) {
        const folder = folderMap[type]
        if (!folder) {
                const errMsg = `Invalid type for git pull: ${type}`
                if (callback) return callback({ status: 'fail', message: errMsg })
                console.error(errMsg)
                return
        }

        exec(`git -C ${folder} pull origin --ff-only`, (err, stdout, stderr) => {
                if (err) {
                        if (callback) {
                                callback({
                                        status: 'fail',
                                        message: 'Git pull failed',
                                        error: stderr.trim()
                                })
                        } else {
                                console.error(`[Git Pull] Failed in ${folder}:`, stderr.trim())
                        }
                        return
                }

                if (callback) {
                        callback({
                                status: 'success',
                                type,
                                folder,
                                output: stdout.trim()
                        })
                } else {
                        console.log(`[Git Pull] Success in ${folder}:`, stdout.trim())
                }
        })
}

function dockerDeploy(type, tag, callback) {
        const imagePrefix = IMAGE_PREFIX_MAP[type]
        const image = `${VALID_USER}/${imagePrefix}:${tag}`
        const composeFile = `mspo/be/docker-compose-${tag}.yml`  // updated path here

        const commands = [
                `docker pull ${image}`,
                `docker compose -f ${composeFile} up -d --remove-orphans`
        ]

        exec(commands.join(' && '), (err, stdout, stderr) => {
                if (err) {
                        if (callback) {
                                callback({
                                        status: 'fail',
                                        message: 'Error during deployment',
                                        error: stderr.trim()
                                })
                        } else {
                                console.error(`[Deploy] Failed for ${tag}:`, stderr.trim())
                        }
                        return
                }

                if (callback) {
                        callback({
                                status: 'success',
                                tag,
                                type,
                                image,
                                output: stdout.trim()
                        })
                } else {
                        console.log(`[Deploy] Success for ${tag}:`, stdout.trim())
                }
        })
}


function startLockCycle(type, tag) {
        locks.set(tag, true)
        rerunScheduled.set(tag, false)

        setTimeout(() => {
                if (rerunScheduled.get(tag)) {
                        console.log(`[LockCycle] Rerun scheduled for tag ${tag}, deploying again...`)
                        dockerDeploy(type, tag, null)
                        // Restart lock cycle for next rerun possibility
                        startLockCycle(type, tag)
                } else {
                        console.log(`[LockCycle] Lock expired for tag ${tag}, no rerun scheduled.`)
                        locks.set(tag, false)
                        rerunScheduled.set(tag, false)
                }
        }, LOCK_TTL_MS)
}

const server = http.createServer((req, res) => {
        if (req.method !== 'POST') {
                res.writeHead(405, { 'Content-Type': 'application/json' })
                return res.end(JSON.stringify({ status: 'error', message: 'Only POST allowed' }))
        }

        let body = ''
        req.on('data', chunk => (body += chunk))
        req.on('end', () => {
                try {
                        const data = JSON.parse(body)
                        const { tag, token, user, type, force } = data

                        if (!tag || !token || !user || !type) throw new Error('Missing required fields')
                        if (token !== VALID_TOKEN || user !== VALID_USER) throw new Error('Invalid token or user')
                        if (!IMAGE_PREFIX_MAP[type] && tag !== 'development') throw new Error(`Invalid type: ${type}`)

                        if (tag === 'development') {
                                if (type === 'be') {
                                        // Run git pull immediately, no lock needed
                                        gitPullForDevelopment(type, (result) => {
                                                const code = result.status === 'success' ? 200 : 500
                                                res.writeHead(code, { 'Content-Type': 'application/json' })
                                                res.end(JSON.stringify(result))
                                        })
                                        return
                                } else {
                                        // For development + other types, return an error or skip git pull but respond
                                        res.writeHead(400, { 'Content-Type': 'application/json' })
                                        res.end(JSON.stringify({
                                                status: 'error',
                                                message: `Git pull for development tag is only supported for type 'be', not '${type}'.`
                                        }))
                                        return
                                }
                        }

                        // For other tags, use locking mechanism for docker deploy
                        const locked = locks.get(tag)

                        if (!locked) {
                                dockerDeploy(type, tag, (result) => {
                                        const code = result.status === 'success' ? 200 : 500
                                        res.writeHead(code, { 'Content-Type': 'application/json' })
                                        res.end(JSON.stringify(result))
                                })
                                startLockCycle(type, tag)
                        } else {
                                if (!rerunScheduled.get(tag)) {
                                        rerunScheduled.set(tag, true)
                                        console.log(`[Request] Rerun scheduled for tag ${tag} during lock.`)
                                } else {
                                        console.log(`[Request] Rerun already scheduled for tag ${tag}, ignoring.`)
                                }
                                res.writeHead(200, { 'Content-Type': 'application/json' })
                                res.end(JSON.stringify({
                                        status: 'queued',
                                        message: `Deployment for tag ${tag} is locked. Rerun scheduled after lock expires.`
                                }))
                        }
                } catch (err) {
                        res.writeHead(400, { 'Content-Type': 'application/json' })
                        res.end(JSON.stringify({ status: 'error', message: err.message }))
                }
        })
})

server.listen(PORT, () => {
        console.log(`🚀 Deploy server listening on port ${PORT}`)
})
