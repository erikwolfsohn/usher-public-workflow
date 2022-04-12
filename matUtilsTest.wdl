version 1.0

workflow matUtilsTest {
    input {
        File user_tree
        File metadata
        File user_samples
        File translation_table
        Int? treesize
        Int subtreesize
    }

    call extractSubtrees {
        input :
            metadata = metadata,
            user_tree = user_tree,
            translation_table = translation_table,
            user_samples = user_samples, 
            treesize = treesize,
            subtreesize = subtreesize
    }

    output {
        #File subtree_table = extractSubtrees.out_tsv
        File auspice_json = extractSubtrees.out_json
        File subtree_nh = extractSubtrees.single_subtree
        File subtree_mutations = extractSubtrees.single_subtree_mutations
    }

}

task extractSubtrees {
    input {
        File user_tree
        File metadata
        File user_samples
        File translation_table 
        Int?  treesize
        Int  subtreesize
        Int  threads = 64
        Int  mem_size = 160
        Int  diskSizeGB = 10
    }
    command <<<
        #matUtils extract -T ~{threads} -i ~{user_tree} -M ~{metadata},~{translation_table} -s ~{user_samples} -X ~{subtreesize} -j "user.json" > matUtils
        matUtils extract -T ~{threads} -i ~{user_tree} -M ~{metadata},~{translation_table} -s ~{user_samples} -X ~{subtreesize} -j "user.json"
    >>>
    output {
        #File out_tsv = "subtree-assignments.tsv"
        #Array[File] subtree_jsons = glob("*subtree*")
        File out_json = "user.json"
        File single_subtree = "single-subtree.nh"
        File single_subtree_mutations = "single-subtree-mutations.txt"
    }
    runtime {
        docker: "yatisht/usher:latest"
        cpu:    threads
        memory: mem_size +" GB"
        disks:  "local-disk " + diskSizeGB + " SSD"
        maxRetries: 3
    }   
}